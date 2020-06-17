Two samplesheets are provided, an 'External' and 'Internal' Samplesheet.

#########################################################################
External samplesheet

The external samplesheet is required for samples which are sequenced externally
and should be processed by the analysis pipeline.
It is also required if you want to import annotated vcf-files.
The import requires that you have entered the respective Projects, Cooperations and
Diseases into the database. You can enter this information via the user interface.

1) Sequence files
If you want to process external sequence files by the analysis
pipeline, you must move the sequence files to a directory named
'/data/isilon/seq/analysis/external/<project_name>'. 
The base directory is hard-coded in Snvedit.pm and can be modified.
The file names must contain the 'Sample ID' or 'Foreign ID'.
The sequence files can be formatted as 'bam' or 'fastq.gz'.
Select the respective format in the field 'File extensions'.

2) vcf-files
If you want to import vcf-files, you can led the field 'File extensions'
empty.
You can test the import with the provided samplesheet
'IHG_External_Sample_Template_v2018.11.csv' and
the provided annotated vcf-file 'S0001.sample.annotated.vcf' (see below).

The test import requires a 'Project', a 'Cooperation' 
and a 'Disease' named 'Controls'. 

#########################################################################
Internal samplesheet

The internal samplesheet is for samples which are to be sequenced
internally. These samples are processed using the LIMS.


#########################################################################
Annotation and import of a vcf-file into EVAdb

S0001.sample.vcf.gz contains simulates data.

Extract the file.
gunzip S0001.sample.vcf.gz

Annotate the file
annotateVCF.pl -i S0001.sample.vcf -se hg19_test -w 5 -o S0001.sample.annotated.vcf

Or use the annotated example file
S0001.sample.annotated.vcf

Import the file
The import requires that an external samplesheet for the same sample has been imported.
The paths to vcftools have to be added to current.config.xml
snvdbExomeInsert_vcf.pl -se hg19_test -i -c gatk S0001.sample.annotated.vcf

