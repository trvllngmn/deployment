function get_register_url() {
  local register=$1
  local phase=$2
  case $phase in
    'beta'|'alpha'|'test') echo https://$register.$phase.openregister.org;;
    'discovery') echo https://$register.cloudapps.digital;;
  esac
}

function delete_register()
{
  local register=$1
  local phase=$2
  local password=$3
  local register_url=$(get_register_url $register $phase)
  echo ""
  echo -n "Delete existing $register data from $phase register? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ; then
      echo "Deleting $register data from $phase $register"
      for i in `seq 1 20`; do
          curl -X DELETE -u openregister:$password $register_url/delete-register-data
          echo " - request: $i of 20"
      done

      echo ""
      echo "Testing consistency of instances"
      for i in `seq 1 20`; do
          register_proof=$(curl -s $register_url/proof/register/merkle:sha-256)
          if [[ $register_proof != *"sha-256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"* ]]; then
              echo "Root hash from one of the instances is not empty - exiting..."
              exit 1
          fi
      done
  fi
}

function load_rsf()
{
  local register=$1
  local phase=$2
  local password=$3
  local register_url=$(get_register_url $register $phase)
  echo ""
  echo -n "Load $register data into $phase register? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ; then
    echo ""
    echo "Loading $register data to $phase"
    echo `cat $OPENREGISTER_BASE/tmp.rsf | curl -X POST -u openregister:$password --data-binary @- $register_url/load-rsf --header "Content-Type:application/uk-gov-rsf"`
  fi
}
