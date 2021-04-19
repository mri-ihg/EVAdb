#! /bin/bash
set -x

##
# Evadb entrypoint script
#
# 1. Set path to database host
#
echo -e "Setting DB_HOST:\t$DB_HOST"
sed -ie "s/host=localhost/host=${DB_HOST}/g" /usr/local/apache2/cgi-bin/Snv.pm

# 2. Set correct cgi-dir
#
sed -ie "s:\t\$cgidir.*:\t\$cgidir     = \"/cgi-bin\";:g" /usr/local/apache2/cgi-bin/Snv.pm

# 3. Create secret files
#
echo -e "Setting up credentials..."
[[ -d $(dirname $DB_CREDS_PATH) ]] || mkdir -p $(dirname $DB_CREDS_PATH)
[[ -d $(dirname $YUBIKEY_CREDS_PATH) ]] ||  mkdir -p $(dirname $YUBIKEY_CREDS_PATH)
echo -e "dblogin:$DB_USER\ndbpasswd:$DB_PASSWD" > $DB_CREDS_PATH
echo -e "id:$YUBIKEY_ID\napi:$YUBIKEY_APIKEY" > $YUBIKEY_CREDS_PATH

sed -ie "s:/srv/tools/textreadonly.txt:${DB_CREDS_PATH}:g" /usr/local/apache2/cgi-bin/Snv.pm
sed -ie "s:/srv/tools/textreadonly2.txt:${YUBIKEY_CREDS_PATH}:g" /usr/local/apache2/cgi-bin/Snv.pm


# Add sed for VEP, new:
sed -ie "s:/usr/local/packages/seq/ensembl-tools-release-102/ensembl-vep/vep:/opt/ensembl-vep/vep:g" /usr/local/apache2/cgi-bin/Snv.pm
# old:
sed -ie "s:/usr/local/packages/seq/ensembl-tools-release-85/scripts/variant_effect_predictor/variant_effect_predictor.pl:/opt/ensembl-vep/vep:g" /usr/local/apache2/cgi-bin/Snv.pm

## remove path to config for VEP
# sed -ie '\|--dir /data/mirror/vep|d' /usr/local/apache2/cgi-bin/Snv.pm
sed -ie "s:--dir /data/mirror/vep:--dir /root/.vep --warning_file /tmp/vep_warnings.txt:g" /usr/local/apache2/cgi-bin/Snv.pm
sed -ie "s:--dir /data/mirror/vep:--dir /root/.vep --warning_file /tmp/vep_warnings_report.txt:g" /usr/local/apache2/cgi-bin/Report.pm



## wget ftp://ftp.ccb.jhu.edu/pub/software/genesplicer/GeneSplicer.tar.gz
## tar -xzf GeneSplicer.tar.gz
sed -ie "s:/usr/local/packages/seq/GeneSplicer:/opt/GeneSplicer:g" /usr/local/apache2/cgi-bin/Snv.pm

## use fasta from outside (provide path in .env and docker-compose.yml), new
sed -ie "s:/data/mirror/vep/homo_sapiens/102_GRCh37/Homo_sapiens.GRCh37.75.dna_sm.primary_assembly.fa:/reference/human_g1k_v37_decoy.fasta:g" /usr/local/apache2/cgi-bin/Snv.pm
# old:
sed -ie "s:/data/mirror/vep/homo_sapiens/85_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz:/reference/human_g1k_v37_decoy.fasta:g" /usr/local/apache2/cgi-bin/Snv.pm
sed -ie "s:/data/mirror/vep/homo_sapiens/85_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz:/reference/human_g1k_v37_decoy.fasta:g" /usr/local/apache2/cgi-bin/Report.pm



set +x
# Start httpd
#
if [[ ! $1 == "bash" ]]; then
  httpd-foreground
else
  httpd-foreground &
  bash
fi
