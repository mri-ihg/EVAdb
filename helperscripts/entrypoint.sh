#! /bin/bash

# Give mysql time to start
sleep 20

echo -e "########################################\n# EVAdb Init\n########################################"

/src/make_db.sh
/src/make_user.sh
# /src/make_annotation.sh
bash
exit 0