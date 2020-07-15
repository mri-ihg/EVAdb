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

set +x
# Start httpd
#
if [[ ! $1 == "bash" ]]; then
  httpd-foreground
else
  httpd-foreground &
  bash
fi