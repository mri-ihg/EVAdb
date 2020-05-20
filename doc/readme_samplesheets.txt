Two samplesheets are provided.

The external samplesheet is for samples which are sequenced externally
and for which fastq.gz or bam files are available.
Use the file 'IHG_External_Sample_Template_v2018.11.csv'
to test the import.
The import require a 'Project' an 'Cooperation' and a disease
'Controls'. You can enter these informations within the user interface.
#You also have to place a dummy file in 
#/data/isilon/seq/analysis/external/<project_name>/control1_fastq.gz

The internal samplesheet is for samples which are to be sequenced
internally. These samples are processed using the LIMS.


#########################################################################
# Annotate and import a vcf-file into EVAdb

# S0001.sample.vcf.gz contains simulates data.

# Extract the file.
gunzip S0001.sample.vcf.gz

# Annotate the file
annotateVCF.pl -i S0001.sample.vcf -se hg19_test -w 5 -o S0001.sample.annotated.vcf

# Or use the annotated example file
S0001.sample.annotated.vcf

# Import the file
# The import requires that an external samplesheet for the same sample has been imported.
# The paths to vcftools have to be added to current.config.xml
snvdbExomeInsert_vcf.pl -se hg19_test -i S0001.sample.annotated.vcf

