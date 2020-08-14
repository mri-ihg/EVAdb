#!/bin/bash

# requires morbidmap.txt from OMIM in datadir
# requires genemap2.txt from OMIM in datadir

function usage {
    echo -e "omim_download.sh\n\nParse and import omim genemap2 and morbidmap data.\n"
    echo -e "Usage: omim_download.sh -d <DATA_DIR> -s <SCRIPT_DIR> -u <DB_USER> -r <DB_HOST> -p <DB_OWD>\n"
    echo -e "Arguments:\n\t-d\tData directory\n\t-s\tScript directory containing parse_omim.pl and omim2gene.pl\n\t-u\tDatabase user (required)\n\t-p\tDatabase password (required)\n\t-r\tDatabase host\n\t-h\tThis help."
}

while getopts "hs:d:u:p:r:" arg; do
  case $arg in
    h) 
      usage
      exit 0
      ;;
    s)
      SCRIPT_DIR=$OPTARG
      ;;
    d)
      DATA_DIR=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    p)
      PASSWORD=$OPTARG
      ;;
    r)
      HOST=$OPTARG
      ;;
  esac
done

if [ -z "$SCRIPT_DIR" ]; then
  SCRIPT_DIR=$PWD
fi

if [ -z "$DATA_DIR" ]; then
  DATA_DIR=$PWD
fi

if [ -z "$USER" ]; then
  echo "Error: No database user specified."
  usage
  exit 1
fi

if [ -z "$PASSWORD" ]; then
  echo "Error: No database password specified."
  usage
  exit 1
fi

if [ -z "$HOST" ]; then
  HOST="localhost"
fi

##############################################################################
# generates exomhg19.omim. Maps OMIM diseases to OMIM genes.
# requires morbidmap.txt and genemap2.txt (for inheritance)
##############################################################################

$SCRIPT_DIR/parse_omim.pl $DATA_DIR $SCRIPT_DIR
mysql -u $USER -p"${PASSWORD}" -h $HOST exomehg19 < $SCRIPT_DIR/omim.sql
mysqlimport -u $USER -p"${PASSWORD}" -L exomehg19 -h $HOST  $SCRIPT_DIR/omim.txt

##############################################################################
# update gene tables with OMIM gene numbers
# requires genemap2.txt 
##############################################################################

$SCRIPT_DIR/omim2gene.pl $DATA_DIR $SCRIPT_DIR $USER $PASSWORD $HOST exomehg19plus
