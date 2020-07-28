#! /bin/bash

function import_file {
  DB=$(basename $1 | cut -d'_' -f1)
  if [[ "$DB" = "hgmd" ]]; then
    DB="hgmd_pro"
  fi
  mysql -L -u ${DB_USER} -p${DB_PASSWD} -h ${DB_HOST} $DB < $(realpath "$1")
}

if [[ $INIT_DB = "1" ]]; then
  echo "Creating database..."

  for db in "exomehg19" "exomehg19plus" "exomevcf" "exomevcfe" "solexa" "ClinVar" "hgmd_pro" "hg19"; do
    mysqladmin create $db -u ${DB_USER} -p${DB_PASSWD} -h ${DB_HOST}
  done

  # Import nodata dumps first
  for f in $(find /database -type f -name "*_nodata.dmp"); do
    import_file $f
  done

  for f in $(find /database -type f -name "*.dmp" ! -name "*nodata*"); do
    import_file $f
  done

  echo "Creating database user..."
  CREATE_USER_SCRIPT=$(mktemp)
  echo -e "DROP USER IF EXISTS '$DB_USER_NONPRIV'@'%';" > $CREATE_USER_SCRIPT
  echo -e "CREATE USER '$DB_USER_NONPRIV'@'%' IDENTIFIED BY '$DB_PASSWD_NONPRIV';" >> $CREATE_USER_SCRIPT
  echo -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER_NONPRIV'@'%';" >> $CREATE_USER_SCRIPT
  mysql -u $DB_USER -p${DB_PASSWD} -h ${DB_HOST} mysql < $CREATE_USER_SCRIPT

  echo "Finished setting up database..."
fi