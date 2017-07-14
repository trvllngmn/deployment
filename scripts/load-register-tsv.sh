#!/bin/bash
set -e
source ./includes/git-update.sh
source ./includes/slack-notify.sh
source ./includes/register-actions.sh
source ./includes/set-vars.sh

usage()
{
  echo "usage: ./load-register-tsv.sh [register] [phase] [tsvfile relative to root] [local|remote] [optional data dir relative to root if not REGISTER-data]"
}

# validation check number of args but other validation is done in python script
if [ $# -lt 4 ]; then
  echo "error: not enough arguments"
  usage
  exit 1
fi

REGISTER=$1
PHASE=$2
TSV="$OPENREGISTER_BASE/$3"
METADATA_SOURCE=$4
DATA_DIR=${5:-"$1-data"}

update_registers_pass

update_data_repo 'registry-data' 

update_data_repo $DATA_DIR

echo "converting $TSV to RSF"
if [ "$METADATA_SOURCE" = 'local' ]
then
  python3 $OPENREGISTER_BASE/deployment/scripts/rsfcreator.py $REGISTER $PHASE --tsv $TSV --prepend_metadata --register_data_root $OPENREGISTER_BASE > $OPENREGISTER_BASE/tmp.rsf
else
  python3 $OPENREGISTER_BASE/deployment/scripts/rsfcreator.py $REGISTER $PHASE --tsv $TSV --prepend_metadata > $OPENREGISTER_BASE/tmp.rsf
fi

PASSWORD=`PASSWORD_STORE_DIR=~/.registers-pass pass $PHASE/app/mint/$REGISTER`

# notify_slack "Deleting data from $PHASE $REGISTER - $USERNAME"

delete_register $REGISTER $PHASE $PASSWORD

#notify_slack "Loading data to $PHASE $REGISTER - $USERNAME"

load_rsf $REGISTER $PHASE $PASSWORD

cat "$OPENREGISTER_BASE/tmp.rsf"
rm $OPENREGISTER_BASE/tmp.rsf
