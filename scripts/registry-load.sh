#!/bin/bash
set -e

echo "usage: ./scripts/registry-load.sh [registry] [phase]"
echo ""

REGISTRY=$1
PHASE=$2
echo "registry: $REGISTRY"
echo "phase: $PHASE"

echo ""
[[ -e ../registry-data ]] || echo "cloning registry-data repo"
[[ -e ../registry-data ]] || (cd .. && git clone git@github.com:openregister/registry-data.git)
echo "../registry-data repo: checkout master && pull"
cd ../registry-data && git checkout master && git pull --rebase

echo ""
echo "Get credentials for $PHASE registry data"
[[ -e ~/.registers-pass ]] || echo "cloning credentials repo to ~/.registers-pass"
[[ -e ~/.registers-pass ]] || (cd ~ && git clone git@github.com:openregister/credentials.git .registers-pass)
PASSWORD=`PASSWORD_STORE_DIR=~/.registers-pass pass $PHASE/app/mint/register`

cd ../deployment

echo ""
echo "Downloading $PHASE field-records.json"
rm -f field-records.json
curl -sS https://field.$PHASE.openregister.org/records.json > field-records.json

echo ""
echo "Serialize registry config tsv to $REGISTRY.rsf"
mkdir -p ./tmp
cp ../registry-data/data/$PHASE/registry/$REGISTRY.yaml ./tmp
echo "serializer yaml field-records.json tmp $REGISTRY > $REGISTRY.rsf"
serializer yaml field-records.json tmp registry -excludeRootHash > $REGISTRY.rsf

echo ""
echo -n "Load $REGISTRY data into $PHASE registry register? (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ; then
  echo ""
  echo "Loading $REGISTRY configuration to $PHASE registry register"
  echo `cat $REGISTRY.rsf | curl -X POST -u openregister:$PASSWORD --data-binary @- https://registry.$PHASE.openregister.org/load-rsf --header "Content-Type:application/uk-gov-rsf"`
fi

echo ""
echo "Removing temporary files"
rm -f tmp/*.yaml
rm -f $REGISTRY.rsf
rm -f field-records.json

echo ""
echo "Done!"
echo ""
