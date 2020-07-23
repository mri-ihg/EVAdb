#! /usr/bin/env python3

import intervaltree
import gzip
import logging
import time
import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base
import argparse

logger = logging.getLogger('DGV')
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s %(name)-3s [%(levelname)7s]:\t%(message)s'
)
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)
logger.propagate = False

log_level = {
    'debug': logging.DEBUG,
    'info': logging.INFO,
    'warning': logging.WARNING,
    'error': logging.ERROR,
}

##
# Default values
INPUT_FILE="/home/brand/Projects/evadb/legacy/init/src/dgv/dgvMerged.txt.gz"
MYSQL_USER="root"
MYSQL_PASSWD="secr3t"
MYSQL_DB="db"
MYSQL_HOST="localhost"
MYSQL_TABLENAME="dgvbp"

parser = argparse.ArgumentParser(
    prog="DGV",
    description="Read dgv file and insert coverage statistics per base into database",
    usage="%(prog)s [options] -i <INPUT>",
)

parser.add_argument(
    '--input-file', '-i',
    default=INPUT_FILE,
    help="Path to input dgv file"
)
parser.add_argument(
    '--user', '-u',
    default=MYSQL_USER,
    help="Mysql user to connect to db instance"
)
parser.add_argument(
    '--password', '-p',
    default=MYSQL_PASSWD,
    help='Mysql password to connect to db instance'
)
parser.add_argument(
    '--db', '-d',
    default=MYSQL_DB,
    help='Mysql db to connect to'
)
parser.add_argument(
    '--host', '-r',
    default=MYSQL_HOST,
    help='Mysql host to connect to'
)
parser.add_argument(
    '--table', '-t',
    default=MYSQL_TABLENAME,
    help='Mysql tablename to insert into'
)
parser.add_argument(
    '--batch-size',
    default=1000,
    help="Mysql insert batch size"
)
parser.add_argument(
    '--verbose',
    type=str,
    help="Set logging level",
    default='info',
    choices=log_level.keys()
)
args = parser.parse_args()
logger.setLevel(log_level[args.verbose])

##
# ORM
Base = declarative_base()
class Dgvbp(Base):
    __tablename__ = args.table
    chrom = sqlalchemy.Column(sqlalchemy.String, primary_key=True)
    start = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)
    depth = sqlalchemy.Column(sqlalchemy.Integer)

def read_file(file_name):
    if file_name.endswith('.gz'):
        open_fn = gzip.open
    else:
        open_fn = open
    with open_fn(file_name, 'r') as f:
        for line in f:
            (chrom, start, end) = line.decode().split("\t")[1:4]
            yield (chrom.strip('chr'), int(start), int(end))

def make_batch(chr_trees, batch_size=1000):
    batch_start_time = time.time()
    processed_items = 0
    values = []
    for chrom, tree in chr_trees.items():
        for interval in tree:
            for i in range(interval.begin, interval.end):
                values.append({
                    'chrom': chrom,
                    'start': i,
                    'depth': interval.data
                })
                processed_items += 1
                if len(values) % batch_size == 0:
                    logger.info("Processed {} positons. Last record: {}:{}. Elapsed time: {}".format(
                        processed_items,
                        chrom,
                        i,
                        time.time() - batch_start_time
                    ))
                    yield values
                    values = []
    yield values

def read_and_insert(input_file, user, password, host, db, table, batch_size):
    start_time = time.time()
    chr_trees = {}
    logger.info("Reading file: {}".format(input_file))
    for idx, pos in enumerate(read_file(input_file)):
        chrom, start, end = pos
        if chrom not in chr_trees:
            chr_trees[chrom] = intervaltree.IntervalTree()
        current_tree = chr_trees[chrom]
        overlap = current_tree[start:end]
        if overlap:
            # interval found -> split interval
            sorted_overlap = list(sorted(overlap))
            for n_iv, interval in enumerate(sorted_overlap):
                if n_iv < len(sorted_overlap) - 1:
                    next_interval = sorted_overlap[n_iv+1]
                else:
                    next_interval = None
                if n_iv == 0 and interval.begin > start:
                    # total covered region extended by start <-> overlap_start
                    current_tree[start:interval.begin] = 1
                current_value = interval.data
                if n_iv == 0 and interval.begin < start:
                    current_tree.discard(interval)
                    current_tree[interval.begin:start] = current_value

                if end < interval.end:
                    # overlap ends in interval, split and adjust coverage
                    current_tree.discard(interval)
                    new_start = start if interval.begin < start else interval.begin
                    current_tree[new_start:end] = current_value + 1
                    current_tree[end:interval.end] = current_value
                elif n_iv == len(sorted_overlap) and end > interval.end:
                    # overlap extends covered region
                    current_tree.discard(interval)
                    new_start = start if interval.begin < start else interval.begin
                    current_tree[new_start:interval.end] = current_value + 1
                    current_tree[interval.end:end] = 1
                elif end > interval.end:
                    # overlap closes gap to next overlap
                    current_tree.discard(interval)
                    new_start = start if interval.begin < start else interval.begin
                    current_tree[new_start:interval.end] = current_value + 1
                    if (next_interval is not None
                            and abs(interval.end - next_interval.begin) > 0
                            and next_interval.begin < end
                    ):
                        # Gap between two intervals
                        current_tree[interval.end:next_interval.begin] = 1
        else:
            current_tree[start:end] = 1
        if idx % 10000 == 0:
            logger.info("Processed {} records. Last position: {}:{}. Elapsed time: {}s".format(
                idx,
                chrom,
                start,
                round(time.time() - start_time)
            ))

    logger.info("Connecting to database...")

    db_engine = sqlalchemy.create_engine("mysql://{user}:{passwd}@{host}/{dbname}".format(
        user=user,
        passwd=password,
        host=host,
        dbname=db,
    ), echo=True)

    logger.info("Writing records to database...")
    with db_engine.connect() as connection:
        for values in make_batch(chr_trees, batch_size=batch_size):
            with connection.begin() as transaction:
                try:
                    connection.execute(Dgvbp.__table__.insert(), values)
                except Exception as e:
                    transaction.rollback()
                    logger.error("Caught db exception...")
                    logger.error(e)
                else:
                    transaction.commit()
                    logger.info("Committed chr{}:{}".format(
                        values[-1]['chrom'],
                        values[-1]['start']
                    ))


read_and_insert(
    args.input_file,
    args.user,
    args.password,
    args.host,
    args.db,
    args.table,
    args.batch_size,
)