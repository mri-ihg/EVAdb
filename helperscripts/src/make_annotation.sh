#! /bin/bash

echo "Importing annotation databases..."

sed -ie "s/SERVER13/${DB_HOST}/g" /src/annotation/current.config.xml
sed -ie "s:<host>localhost</host>:<host>${DB_HOST}</host>:g"
sed -ie "s/DBPORT/3306/g" /src/annotation/current.config.xml
sed -ie "s/DBUSER/${DB_USER}/g" /src/annotation/current.config.xml
sed -ie "s/DBPWD/${DB_PASSWD}/g" /src/annotation/current.config.xml

DBNSFP="/library/dbNSFP${DBNSFP_VERSION}.zip"
CADD="/library/whole_genome_SNVs.tsv.gz"
GNOMAD_WES="/library/gnomad.exomes.${GNOMAD_RELEASE}.sites.vcf.bgz"
GNOMAD_WGS="/library/gnomad.genomes.${GNOMAD_RELEASE}.sites.vcf.bgz"

if [[ $IMPORT_DBNSFP = "1" && -e "$DBNSFP" ]]; then
  echo -e "Found $DBNSFP"
  echo -e "Importing polyphen and sift for hg19"

  EXTRACT_DIR=$(mktemp -d)
  unzip "$DBNSFP" -d $EXTRACT_DIR
  time perl /src/annotation/fillAnnotationTables.pl -se hg19_test -chrperfix -db $EXTRACT_DIR -p -s
else
  echo -e "Could not find dbnsfp at $DBNSFP"
fi

if [[ $IMPORT_CADD = "1" && -e "$CADD" ]]; then
  echo -e "Found $CADD"
  echo -e "Importing $CADD"

  time perl /src/annotation/fillAnnotationTables.pl -se hg19_test -chrprefix -c "$CADD"
else
  echo -e "Could not find cadd at $CADD"
fi

if [[ $IMPORT_GNOMAD = "1" && -e "$GNOMAD_WES" && -e "$GNOMAD_WGS" ]]; then
  echo -e "Found gnomad files ($GNOMAD_WES, $GNOMAD_WGS)"
  echo -e "Importing gnomad"

  time perl /src/annotation/fillAnnotationTables.pl -se hg19_test -chrprefix -g "$(basename $GNOMAD_WES)"
else
  echo -e "Could not find gnomad data"
fi

if [[ $IMPORT_DGV = "1" ]]; then
  echo -e "Importing dgv entries..."
  time perl /src/dgv.pl
fi

if [[ $IMPORT_CLINVAR = "1" ]]; then
  echo -e "Import ClinVar..."
  time bash -x /src/ClinVarImport/ClinVarForCron.sh
fi

if [[ $IMPORT_UCSC = "1" ]]; then
  echo -e "Import UCSC tables for hg 19..."
  mysqldump --lock-tables=false --user=genomep --password=password --host=genome-mysql.cse.ucsc.edu hg19 knownGene kgXref knownGenePep refGene | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} hg19
  echo "delete from hg19.knownGene where chrom='chrM';" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} hg19
  mysqldump --lock-tables=false --user=genomep --password=password --host=genome-mysql.cse.ucsc.edu hg38 wgEncodeGencodeBasicV20 | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} hg19

  echo "CREATE VIEW knownGeneSymbol AS select kg.name AS name,kg.chrom AS chrom,kg.strand AS strand,kg.txStart AS txStart,kg.txEnd AS txEnd,kg.cdsStart AS cdsStart,kg.cdsEnd AS cdsEnd,kg.exonCount AS exonCount,kg.exonStarts AS exonStarts,kg.exonEnds AS exonEnds,kg.proteinID AS proteinID,kg.alignID AS alignID,x.geneSymbol AS geneSymbol from (knownGene kg join kgXref x on((x.kgID = kg.name)))" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} hg19
  echo "insert into gene (geneSymbol,nonsynpergene,delpergene) select distinct replace(geneSymbol , ' ','_'),0,0 from hg19.knownGeneSymbol;" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} exomehg19plus
  echo "insert into gene (geneSymbol,nonsynpergene,delpergene) select distinct replace(name2 , ' ','_'),0,0 from hg19.refGene;" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} exomehg19
  echo "insert into transcript (idgene,name,chrom,exonStarts,exonEnds) select (select idgene from exomehg19.gene where geneSymbol=replace(r.name2 , ' ','_')),name,chrom,exonStarts,exonEnds from hg19.refGene r where cdsEnd>cdsStart;" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} exomehg19

  # add the mitochondrial genome from hg38
  echo "insert into exomehg19plus.gene (genesymbol) ( select name2 from hg19.wgEncodeGencodeBasicV20 where chrom='chrM' group by name2);" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} exomehg19plus
  echo "insert into exomehg19.gene (genesymbol) ( select name2 from hg19.wgEncodeGencodeBasicV20 where chrom='chrM' group by name2);" | mysql -h $DB_HOST -u $DB_USER -p${DB_PASSWD} exomehg19
fi

if [[ $IMPORT_CDSDB = "1" ]]; then
  echo -e "Import coding sequenc table..."

  REFERENCE=$(ls /library/*.fasta)
  sed -ie "s:/PATHTO/hg19/chromosome/hg19.fa:/library/$REFERENCE:g" /src/annotation/current.config.xml

  time perl /src/annotation/cdsdb.pl -se hg19_plus
fi