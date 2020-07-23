#!/bin/bash

##############################################################################
#  ClinVar download and import for cron job
##############################################################################

#cron
#0 6 * * 1   <path>/ClinVarForCron.sh  

scriptdir=/src/ClinVarImport
host="$DB_HOST"
user="$DB_USER"
password="$DB_PASSWD"


#download
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar.vcf.gz -O $scriptdir/clinvar.vcf.gz
gunzip -f $scriptdir/clinvar.vcf.gz
if [ "$?" != "0" ]
then
	mailx -s "ERROR in ClinVarForCron.pl" email@address </dev/null
	exit -1;
fi;

# parse clinvar.vcf.gz, generate tab-separated file
# for import into exomehg19. Output file is 'clinvar.txt'
$scriptdir/parse_vcf.pl

# create table exomehg19.clinvar
mysql -h $host -u $user -p$password hg19 < $scriptdir/clinvar.sql

# import data into clinvar table
mysqlimport -h $host -u $user -p$password -L hg19 $scriptdir/clinvar.txt
