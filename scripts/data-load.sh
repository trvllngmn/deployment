#!/bin/bash
set -e

echo "usage: ./scripts/data-load.sh [register] [phase]"
echo ""

REGISTER=$1
PHASE=$2
echo "register: $REGISTER"
echo "phase: $PHASE"

echo ""
echo "Downloading $PHASE field-records.json"
rm -f field-records.json
curl -sS https://field.$PHASE.openregister.org/records.json > field-records.json

echo ""
[[ -e ../$REGISTER-data ]] || echo "cloning $REGISTER-data repo"
[[ -e ../$REGISTER-data ]] || (cd .. && git clone git@github.com:openregister/$REGISTER-data.git)
echo "../$REGISTER-data repo: checkout master && pull"
cd ../$REGISTER-data && git checkout master && git pull --rebase

echo ""
echo "Get credentials for $PHASE $REGISTER"
[[ -e ~/.registers-pass ]] || echo "cloning credentials repo to ~/.registers-pass"
[[ -e ~/.registers-pass ]] || (cd ~ && git clone git@github.com:openregister/credentials.git .registers-pass)
PASSWORD=`PASSWORD_STORE_DIR=~/.registers-pass pass $PHASE/app/mint/$REGISTER`

echo ""
echo "Serialize tsv to $REGISTER.rsf"
cd ../deployment
TSVFILE="../$REGISTER-data/data/$PHASE/$REGISTER/$REGISTER"
if [[ -e $TSVFILE"es.tsv" ]]; then
  serializer tsv field-records.json $TSVFILE"es.tsv" $REGISTER > $REGISTER.rsf
elif [[ -e $TSVFILE"s.tsv" ]]; then
  serializer tsv field-records.json $TSVFILE"s.tsv" $REGISTER > $REGISTER.rsf
elif [[ -e $TSVFILE".tsv" ]]; then
  serializer tsv field-records.json $TSVFILE".tsv" $REGISTER > $REGISTER.rsf
fi

echo ""
echo -n "Delete existing $REGISTER data from $PHASE register? (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ; then
    echo ""
    echo "Deleting $REGISTER data from $PHASE"
    for i in `seq 1 20`; do
        curl -X DELETE -u openregister:$PASSWORD https://$REGISTER.$PHASE.openregister.org/delete-register-data
        echo " - request: $i of 20"
    done

    echo ""
    echo "Testing consistency of instances"
    for i in `seq 1 20`; do
        REGISTER_PROOF=$(curl -s https://$REGISTER.$PHASE.openregister.org/proof/register/merkle:sha-256)
        if [[ $REGISTER_PROOF != *"sha-256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"* ]]; then
            echo "Root hash from one of the instances is not empty - exiting..."
            exit 1
        fi
    done  
fi

echo ""
echo -n "Load $REGISTER data into $PHASE register? (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ; then
  echo ""
  echo "Loading $REGISTER data to $PHASE"
  echo `cat $REGISTER.rsf | curl -X POST -u openregister:$PASSWORD --data-binary @- https://$REGISTER.$PHASE.openregister.org/load-rsf --header "Content-Type:application/uk-gov-rsf"`
fi

echo ""
echo "Removing temporary files"
rm $REGISTER.rsf
rm field-records.json

echo ""
echo "Done!"
echo ""
