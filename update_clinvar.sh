#! /bin/bash
(
set -ex

cd /data1/EVAdb

docker-compose run --entrypoint="/src/ClinVarImport/ClinVarForCron.sh" evadb_init ) > /var/log/update-clinvar.log 2>&1
