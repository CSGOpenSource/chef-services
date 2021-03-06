#!/bin/bash

#
# Please provide an IP/FQDN for your chef server: domain.com
#
# Hab package?
#

ERROR_CODE_101=101
ERROR_CODE_TEXT_101="Value required for option: -c|--chef-server-fqdn"
ERROR_CODE_101=102
ERROR_CODE_TEXT_102="Value required for option: -a|--chef-automate-fqdn)"
ERROR_CODE_101=103
ERROR_CODE_TEXT_103="Value required for option: -b|--build-node-fqdn"


usage="
This is an installer for Chef. It will install Chef Server, Chef Automate, and a build node for Automate.\n
It will install the Chef server on the system you run this script from.\n

You must specify the following options:\n

-c|--chef-server-fqdn         REQUIRED: The FQDN you want the Chef Server configured to use.\n
-a|--chef-automate-fqdn       The FQDN of the Chef Automate server.\n
-b|--build-node-fqdn          The FQDN of the build node.\n
-u|--user                     The ssh username we'll use to connect to other systems.\n
-p|--password                 The ssh password we'll use to connect to other systems.\n
-i|--install-dir              The directory to use for the installer.\n
-k|--key                      SSH Key.\n

If only -c is specified the local system will be configured with a Chef Server install. \n
"

if [ $# -eq 0 ]; then
  echo -e $usage
  exit 1
fi

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -c|--chef-server-fqdn)
    CHEF_SERVER_FQDN="$2"
    if [ -z $CHEF_SERVER_FQDN ]; then
        echo $ERROR_CODE_TEXT_101
        exit $ERROR_CODE_101
    fi
    shift # past argument
    ;;
    -a|--chef-automate-fqdn)
    CHEF_AUTOMATE_FQDN="$2"
    if [ -z $CHEF_AUTOMATE_FQDN ]; then
        echo $ERROR_CODE_TEXT_102
        exit $ERROR_CODE_102
    fi
    shift # past argument
    ;;
    -b|--build-node-fqdn)
    CHEF_BUILD_FQDN="$2"
    if [ -z $CHEF_BUILD_FQDN ]; then
        echo $ERROR_CODE_TEXT_103
        exit $ERROR_CODE_103
    fi
    shift # past argument
    ;;
    -u|--user)
    CHEF_USER="$2"
    shift
    ;;
    -p|--password)
    CHEF_PW="$2"
    shift
    ;;
    -i|--install-dir)
    INSTALL_DIR="$2"
    shift
    ;;
    -h|--help)
    echo -e $usage
    exit 0
    ;;
    -k|--key)
    KEY_FILE_LOCATION="$2"
    shift
    ;;
    *)
    echo "Unknown option $1"
    echo -e $usage
    exit 1
    ;;
esac
shift # past argument or value
done

echo " -------------------------- Step! 1 -----------------------------------------"

# Do you want to connect by ssh key or user/pass?
# Please provide a ssh username:

# --or--
# Please provide a ssh key:
#
# ---------- Chef Server ----------
# ->install Chef
if [ -z $INSTALL_DIR ]; then
  INSTALL_DIR=/tmp
fi

echo " -------------------------- Step! 2 -----------------------------------------"

mkdir -p $INSTALL_DIR/chef_installer/cookbooks/installer/recipes/
mkdir -p $INSTALL_DIR/chef_installer/.chef/cache/
cd $INSTALL_DIR/chef_installer
curl -o $INSTALL_DIR/chef_installer/cookbooks/installer/recipes/installer.rb https://raw.githubusercontent.com/stephenlauck/chef-services/master/files/default/installer.rb
if [ ! -d "/opt/chefdk" ]; then
  curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chefdk -d $INSTALL_DIR/chef_installer && rm install.sh
fi
echo "file_cache_path \"$INSTALL_DIR/chef_installer/.chef/cache\"" > solo_installer.rb
echo -e "{\"install_dir\":\"$INSTALL_DIR\"}" > installer.json
chef-client -z -j installer.json -c solo_installer.rb -r 'recipe[installer::installer]'

echo " -------------------------- Step! 3 -----------------------------------------"

echo -e "{\"chef_server\": {\"fqdn\":\"$CHEF_SERVER_FQDN\",\"install_dir\":\"$INSTALL_DIR\"}}" > attributes.json
chef-client -z -j attributes.json --config-option file_cache_path=$INSTALL_DIR -r 'recipe[chef-services::chef-server]'

echo " -------------------------- Step! 4 -----------------------------------------"

# ->upload cookbooks to itself
# ->generate keys, create data_bags
# ->bootstrap Chef to Chef
# ---------- All others -----------
# -> automate,chef-builder1,chef-builder2,chef-builder3,supermarket,compliance.domain.com
# --> bootstrap with correct runlist

PASS="-P $CHEF_PW"
if [ ! -z $KEY_FILE_LOCATION ]; then
  PASS="-i $KEY_FILE_LOCATION"
fi

if [ ! -z $CHEF_AUTOMATE_FQDN ]; then
  echo " -------------------------- Step! 5 -----------------------------------------"
  knife bootstrap $CHEF_AUTOMATE_FQDN -N $CHEF_AUTOMATE_FQDN -x $CHEF_USER $PASS --sudo -r "recipe[chef-services::delivery]" -j "{\"chef_server\":{\"fqdn\":\"$CHEF_SERVER_FQDN\"},\"chef_automate\":{\"fqdn\":\"$CHEF_AUTOMATE_FQDN\"}}" -y --node-ssl-verify-mode none
  if [ ! -z $CHEF_BUILD_FQDN ] ; then
      echo " -------------------------- Step! 6 -----------------------------------------"
      knife bootstrap $CHEF_BUILD_FQDN -N $CHEF_BUILD_FQDN -x $CHEF_USER $PASS --sudo -r "recipe[chef-services::install_build_nodes]" -j "{\"chef_server\":{\"fqdn\":\"$CHEF_SERVER_FQDN\"},\"chef_automate\":{\"fqdn\":\"$CHEF_AUTOMATE_FQDN\"},\"tags\":\"delivery-build-node\"}" -y --node-ssl-verify-mode none
  fi
fi

echo " -------------------------- Step! 7 -----------------------------------------"
chef-client -j attributes.json -r 'recipe[chef-services::chef-server]'

