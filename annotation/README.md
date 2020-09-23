# EVAdb Annotation

This directory contains the Dockerfile and entrypoint for EVAdb's
Pipeline scripts. These scripts include runners for various bioinformatics
tools such as GATK. Additionally, it includes annotation scripts for
importing samples into a running EVAdb instance. Importing samples into
an EVAdb instance is the main use case of this container.

## Software

For the actual contents of the docker image (downloaded during build
time), please see https://github.com/mri-ihg/ngs_pipeline.

## Sample Import

To import a sample into a running EVAdb instance, please use the following
steps:

1. Create a sample sheet and import it using the EVAdb Admin Applications
  "Import External Samplesheet" Option
2. Enter Family Structure (if necessary) using the EVAdb Admin App
3. Build this container
4. Import the sample vcf into the EVAdb instance:

        docker-compose run annotation -vcf <VCF_FILE> -sample <SAMPLE_NAME> -se hg19_plus