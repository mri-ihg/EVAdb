#! /bin/bash

if [[ $INIT_USER = "1" ]]; then
  echo "Creating initial user..."

  echo -e "Username:\t$INITIAL_USER"
  HASH=$(perl -w /src/hash_pw.pl "$INITIAL_USER_PASSWD")

  QUERY_FILE=$(mktemp)
  echo -e "insert into exomevcfe.user (name,password,role,edit,genesearch,yubikey) VALUES ('$INITIAL_USER', '$HASH', 'admin', 1, 1, 0);" > $QUERY_FILE

  mysql -L -u ${DB_USER} -p${DB_PASSWD} -h ${DB_HOST} $DB < $QUERY_FILE
fi