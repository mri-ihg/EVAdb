Use the following script and utilities from 
https://github.com/mri-ihg/ngs_pipeline
to fill the database with external data you need at least:
fillAnnotationTables.pl
Utilities.pm
current.config.xml

Find below a description which files to download and how to import them.
We describe the download for the default human assembly hg19.
One can modify current.config.xml for other species and assemblies.

gnomaAD
Polyphen2
SIFT
ClinVar

#############################################################################
# required software
#############################################################################

First, you have to install the Tabix module for Perl and some Perl modules from cpan.
curl 'https://liquidtelecom.dl.sourceforge.net/project/samtools/tabix/tabix-0.2.5.tar.bz2' > tabix-0.2.5.tar.bz2
tar -xvf tabix-0.2.5.tar.bz2
cd tabix-0.2.5
make
cd perl
perl Makefile.PL
make
make install

cpan install 	diagnostics		
cpan install	Bio::DB::Fasta	
cpan install	File::chmod::Recursive
# give the path to your samtools installation	
LD_LIBRARY_PATH=<PATH_to_samtools_folder>
SAMTOOLS=<PATH_to_samtools_folder
cpan install	Bio::DB::Sam	
	
#############################################################################
Modification of current.config.xml
#############################################################################
You have to modify the current.config.xml

Modifiy the following lines.
They appear in several places in the file.

<host>SERVER13</host>
<port>DBPORT</port>
<user>DBUSER</user>
<password>DBPWD</password>

sed -i 's/SERVER13/<host>/g' current.config.xml
sed -i 's/DBPORT/<port>/g' current.config.xml
sed -i 's/DBUSER/<myuser>/g' current.config.xml
sed -i 's/DBPWD/<mypassword>/g' current.config.xml
	
#############################################################################
# imports
#############################################################################
#Polyphen2 and SIFT
For simplicity, Polyphen2 and SIFT predictions are taken from dbNSFP, a precomputed collection of many prediction and
conservation scores. dbNSFP can be dowloaded here: https://sites.google.com/site/jpopgen/dbNSFP

Download the academic version 3.5a from: for example into ~/sift

https://drive.google.com/file/d/0B60wROKy6OqcRmZLbWd4SW5Yc1U/view?usp=sharing
or 
wget -c ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv3.5a.zip
Unzip the file. The folder then contains dbNSFP tables one per chromosome.

./fillAnnotationTables.pl -se hg19_test -chrprefix -db ~/sift -p -s


#############################################################################
#CADD

Download the following file for example into ~/cadd
wget -c https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh37/whole_genome_SNVs.tsv.gz
This is a single compressed file. Don't unpack the files.

Start the import with:
./fillAnnotationTables.pl -se hg19_test -chrprefix -c ~/cadd/whole_genome_SNVs.tsv.gz


#############################################################################
#gnomAD

Download all exomes for example into ~/gnomad_download
wget -c https://storage.googleapis.com/gnomad-public/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz
This is a single compressed file. Don't unpack the files.

Download all genomes for example into ~/gnomad_download
wget -c https://storage.googleapis.com/gnomad-public/release/2.1.1/vcf/genomes/gnomad.genomes.r2.1.1.sites.vcf.bgz
This is a single compressed file. Don't unpack the files.

Both files have to be in the same folder.

Start the import with:
./fillAnnotationTables.pl -se hg19_test -chrprefix -g ~/gnomad_download

#############################################################################
# UCSC Genome Browser
# Import of tables from UCSC

mysqldump --lock-tables=false --user=genomep --password=password --host=genome-mysql.cse.ucsc.edu hg19 knownGene kgXref knownGenePep refGene | mysql hg19

#############################################################################
# DGV

Use the helperscript dgv.pl to import a table that contains the number of DGV entries
for every genome position.
It takes about 10 hours and requires about 20G memory.



