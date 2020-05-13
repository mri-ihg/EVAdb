# readme for the installation 
# of the required mariadb databases
# use the appropriate user and password

# create databases
mysqladmin  create exomehg19 -u root -p
mysqladmin  create exomevcf -u root -p
mysqladmin  create exomevcfe -u root -p
mysqladmin  create solexa -u root -p
mysqladmin  create ClinVar -u root -p
mysqladmin  create hgmd_pro -u root -p
mysqladmin  create hg19 -u root -p

# import tables
mysql -L exomehg19 < exomehg19_nodata.dmp -u root -p
mysql -L exomevcf < exomevcf_nodata.dmp -u root -p
mysql -L exomevcfe < exomevcfe_nodata.dmp -u root -p
mysql -L solexa < solexa_nodata.dmp -u root -p
mysql -L ClinVar < ClinVar_nodata.dmp -u root -p
mysql -L hgmd_pro < hgmd_pro_nodata.dmp -u root -p

mysql -L solexa < solexa_assay.dmp -u root -p
mysql -L solexa < solexa_barcodes10x.dmp -u root -p
mysql -L solexa < solexa_libpair.dmp -u root -p
mysql -L solexa < solexa_libtype.dmp -u root -p
mysql -L solexa < solexa_runtype.dmp -u root -p
mysql -L solexa < solexa_tag.dmp -u root -p

mysql -L exomehg19 < exomehg19_organism.dmp -u root -p
mysql -L exomehg19 < exomehg19_tissue.dmp -u root -p
mysql -L exomehg19 < exomehg19_diseasegroup.dmp -u root -p

mysql -L hg19 < hg19_pph3_nodata.dmp -u root -p
mysql -L hg19 < hg19_sift_nodata.dmp -u root -p
mysql -L hg19 < hg19_cadd_nodata.dmp -u root -p
mysql -L hg19 < hg19_evs_nodata.dmp -u root -p
mysql -L hg19 < hg19_exacGeneScores_nodata.dmp -u root -p
mysql -L hg19 < hg19_kaviar_nodata.dmp -u root -p
mysql -L hg19 < hg19_clinvar_nodata.dmp -u root -p
mysql -L hg19 < hg19_dgvbp_nodata.dmp -u root -p


# mysqlshow should no show the following databases
mysqlshow -u root -p
+---------------------+
|      Databases      |
+---------------------+
| ClinVar             |
| exomehg19           |
| exomevcf            |
| exomevcfe           |
| hg19                |
| hgmd_pro            |
| information_schema  |
| mysql               |
| performance_schema  |
| solexa              |
+---------------------+


# modification of the config file /etc/my.cnf

# important
# you have to set the following parameter at the end
# of the config file after all include files have been loaded

[mysqld]
sql_mode=''

# database parameters
# the database contains innodb and myisam tables
# only a recommendation
# we use these parameters on a server with 256 GB memory
# you may have to adapt the parameters

innodb_buffer_pool_size = 61G
innodb_buffer_pool_instances = 30
innodb_log_file_size = 2048M
innodb_log_buffer_size = 100M
innodb_thread_concurrency=16
innodb_lock_wait_timeout = 500
innodb_read_io_threads=32
innodb_write_io_threads=32
innodb_io_capacity=500
innodb_flush_method=O_DIRECT

max_connections = 512
key_buffer_size = 10240M
max_allowed_packet = 10M
group_concat_max_len = 40960
table_cache = 3072
sort_buffer_size = 64M
net_buffer_length = 8K
read_buffer_size = 12M
read_rnd_buffer_size = 64M
myisam_sort_buffer_size = 256M
query_cache_size = 16M
thread_cache_size = 8

max_heap_table_size = 256M
tmp_table_size = 2048M

# of course, you have to set the path to
# datadir and tmpdir
# we use a SSD raid of 4.4 TB for the datadir
# and a second SSD raid of 4.4 TB for the tmpdir
# and all other data on the server
# a database with 20,000 Exomes require about 3 TB
 
