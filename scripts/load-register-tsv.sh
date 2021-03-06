#!/bin/bash
set -e
OPENREGISTER_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
echo "OPENREGISTER_BASE - $OPENREGISTER_BASE"

source "$OPENREGISTER_BASE/deployment/scripts/includes/git-update.sh"
source "$OPENREGISTER_BASE/deployment/scripts/includes/register-actions.sh"
source "$OPENREGISTER_BASE/deployment/scripts/includes/set-vars.sh"

usage()
{
  echo "usage: ./load-register-tsv.sh [register] [phase] [tsvfile relative to root] [local|remote] [custodian] [optional data dir relative to root if not REGISTER-data]"
}

# validation check number of args but other validation is done in python script
if [ $# -lt 5 ]; then
  echo "error: not enough arguments"
  usage
  exit 1
fi

REGISTER=$1
PHASE=$2
TSV="$OPENREGISTER_BASE/$3"
METADATA_SOURCE=$4
CUSTODIAN=$5
DATA_DIR=${6:-"$1-data"}

update_registers_pass

update_data_repo 'registry-data'

update_data_repo $DATA_DIR

echo "converting $TSV to RSF"
if [ "$METADATA_SOURCE" = 'local' ]
then
  python3 $OPENREGISTER_BASE/deployment/scripts/rsfcreator.py $REGISTER $PHASE --tsv $TSV --prepend_metadata --custodian "${CUSTODIAN}" --register_data_root $OPENREGISTER_BASE > $OPENREGISTER_BASE/tmp.rsf
else
  python3 $OPENREGISTER_BASE/deployment/scripts/rsfcreator.py $REGISTER $PHASE --tsv $TSV --prepend_metadata --custodian "${CUSTODIAN}" > $OPENREGISTER_BASE/tmp.rsf
fi

PASSWORD=`PASSWORD_STORE_DIR=~/.registers-pass pass $PHASE/app/mint/$REGISTER`

delete_register $REGISTER $PHASE $PASSWORD

load_rsf $REGISTER $PHASE $PASSWORD

rm $OPENREGISTER_BASE/tmp.rsf
