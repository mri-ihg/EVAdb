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
# samtools-0.1.19 required	
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
#Polyphen2 and SIFT for hg19
For simplicity, Polyphen2 and SIFT predictions are taken from dbNSFP, a precomputed collection of many prediction and
conservation scores. dbNSFP can be dowloaded here: https://sites.google.com/site/jpopgen/dbNSFP

Download the academic version 3.5a from: for example into ~/sift

https://drive.google.com/file/d/0B60wROKy6OqcRmZLbWd4SW5Yc1U/view?usp=sharing
or 
wget -c ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv3.5a.zip
Unzip the file. The folder then contains dbNSFP tables one per chromosome.

./fillAnnotationTables.pl -se hg19_test -chrprefix -db ~/sift -p -s


#############################################################################
#CADD for hg19

Download the following file for example into ~/cadd
wget -c https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh37/whole_genome_SNVs.tsv.gz
This is a single compressed file. Don't unpack the files.

Start the import with:
./fillAnnotationTables.pl -se hg19_test -chrprefix -c ~/cadd/whole_genome_SNVs.tsv.gz


#############################################################################
#gnomAD for hg19

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
# DGV for hg19

Use the helperscript dgv.pl to import a table that contains the number of DGV entries
for every genome position.
It takes about 10 hours and requires about 20G memory.

#############################################################################
# UCSC Genome Browser

# Import UCSC tables for hg19
mysqldump --lock-tables=false --user=genomep --password=password --host=genome-mysql.cse.ucsc.edu hg19 knownGene kgXref knownGenePep refGene | mysql hg19
mysqldump --lock-tables=false --user=genomep --password=password --host=genome-mysql.cse.ucsc.edu proteins140122  hgncXref | mysql hg19
# delete the genes on the mitochondrial genome
echo "delete from hg19.knownGene where chrom='chrM';" | mysql hg19

# We use hg38 for the mitochondrial genome
mysqldump --lock-tables=false --user=genomep --password=password --host=genome-mysql.cse.ucsc.edu hg38 wgEncodeGencodeBasicV20 | mysql hg19

# Download and import the information from HGNC
wget ftp://ftp.ebi.ac.uk/pub/databases/genenames/hgnc/tsv/hgnc_complete_set.txt -O hgnc.txt
mysqlimport -L --ignore-lines=1 --fields-terminated-by='\t' --fields-enclosed-by='"' hg19 hgnc.txt

#############################################################################
# Import data into gene tables of EVAdb

# create a view to join UCSC knownGenes with gene symbols
# NOTE: refGene already has the geneSymbol included
echo "CREATE VIEW knownGeneSymbol AS select kg.name AS name,kg.chrom AS chrom,kg.strand AS strand,kg.txStart AS txStart,kg.txEnd AS txEnd,kg.cdsStart AS cdsStart,kg.cdsEnd AS cdsEnd,kg.exonCount AS exonCount,kg.exonStarts AS exonStarts,kg.exonEnds AS exonEnds,kg.proteinID AS proteinID,kg.alignID AS alignID,x.geneSymbol AS geneSymbol from (knownGene kg join kgXref x on((x.kgID = kg.name)))" | mysql hg19

# Add gene names & transcript informations to respective tables
# Here, we use UCSC known genes to annotate variants and RefSeq coding transcripts for coverage information
echo "insert into gene (geneSymbol,nonsynpergene,delpergene) select distinct replace(geneSymbol , ' ','_'),0,0 from hg19.knownGeneSymbol;" | mysql exomehg19plus
echo "insert into gene (geneSymbol,nonsynpergene,delpergene) select distinct replace(name2 , ' ','_'),0,0 from hg19.refGene;" | mysql exomehg19
echo "insert into transcript (idgene,name,chrom,exonStarts,exonEnds) select (select idgene from exomehg19.gene where geneSymbol=replace(r.name2 , ' ','_')),name,chrom,exonStarts,exonEnds from hg19.refGene r where cdsEnd>cdsStart;" | mysql exomehg19
echo "UPDATE exomehg19plus.gene v SET v.hgncId = (SELECT DISTINCT x.hgncId FROM hg19.hgncXref x WHERE  v.genesymbol=x.symbol);" | mysql exomehg19plus
echo "UPDATE exomehg19plus.gene v SET v.approved = (SELECT x.symbol FROM hg19.hgnc x WHERE  v.hgncId=x.hgnc_id);" | mysql exomehg19plus

# add the mitochondrial genome from hg38
echo "insert into exomehg19plus.gene (genesymbol) ( select name2 from hg19.wgEncodeGencodeBasicV20 where chrom='chrM' group by name2);" | mysql exomehg19plus
echo "insert into exomehg19.gene (genesymbol) ( select name2 from hg19.wgEncodeGencodeBasicV20 where chrom='chrM' group by name2);" | mysql exomehg19

#############################################################################
# ClinVar for hg19

Use the the scripts in 'helperscript/ClinVarImport' to import the the ClinVar data for hg19.
Modify path, user and password in ClinVarForCron.sh and run this script.

#############################################################################
# OMIM for hg19
requires the following tables/columns:
hg19.hgncXref (see above)
hg19.hgnc (see above)
update of the hgncID column in exomehg19plus.gene (see above)
update of the approved column in exomehg19plus.gene (see above)

requires morbidmap.txt and genemap2.txt from OMIM
import the data with helperscripts/OMIMimport/omim_download.sh

#############################################################################
# fill coding sequence table, knownGene_cds (required for annotation)

You can import your own vcf-files for short variants if you don't want 
to use the entire analysis pipeline which is provided in combination with EVAdb.

Before you import your own vcf-files, you have to annotate them with 
provided scripts. That works currently only for hg19. It is planned
to move to hg38 and variant effect predicior.

To run the annotation scripts, you need to create an additional table,
knownGene_cds, by the script cdsdb.pl. The script requires the following prerequistes:
- knownGenes table from UCSC (you have already downloaded it in a previous step)
- the fasta file of hg19

hg19 don't allow correct annotation for the mitochondrial genome. We therefore
provide a modifed version of hg19 which combines hg19 with the mitochondrial sequence
of hg38. We also added the decoy regions and removed the pseudoautosomal regions of the
Y-chromosome. This sequence can be downloaded from
https://ihg4.helmholtz-muenchen.de/hg19p/noPAR.hg19_decoy.fa.gz


How to run cdsdb.pl (this step takes some hours)
./cdsdb.pl -se hg19_plus



