#! /bin/bash

echo -e "----------- EVAdb Annotation and Import -----------"

# zcat ~/data/B18-0309.vcf.gz | awk '{ if ( $1 ~ "#" ) { print $0 } else { print "chr"$0 } }' > ~/data/B18-0309.chr.vcf

##
# Set configuration
sed -ie "s/SERVER13/${DB_HOST}/g" /pipeline/current.config.xml
sed -ie "s:<host>localhost</host>:<host>${DB_HOST}</host>:g" /pipeline/current.config.xml
sed -ie "s/DBPORT/3306/g" /pipeline/current.config.xml
sed -ie "s/DBUSER/${DB_USER}/g" /pipeline/current.config.xml
sed -ie "s/DBPWD/${DB_PASSWD}/g" /pipeline/current.config.xml
sed -ie "s:/PATHTO/hg19/chromosome/snpEff/data/:/anno_db/:g" /pipeline/current.config.xml
sed -ie "s:/PATHTO:/usr/local/packages:g" /pipeline/current.config.xml

##
# Overwrite parameters in perl module
sed -ie "s/host=localhost/host=${DB_HOST}/g" /pipeline/Utilities.pm

##
# Path to reference genome build
LIBS=$(ls /library/*.fasta)
REFERENCE=${LIBS%$'\n'*}
sed -ie "s:<reference>.*</reference>:<reference>$REFERENCE</reference>:g" /pipeline/current.config.xml

if [[ ! $1 == "bash" ]]; then
  /pipeline/externalPipelineImport.pl $@
else
  bash
fi