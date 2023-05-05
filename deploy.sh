#!/bin/bash
set -e

function usage() {
    echo
    echo "    Usage: $0 install_dir museum prod|dev <optional-tag>"
    echo
    echo "    e.g.   $0 202208170955.cinefiles cinefiles prod 2.4.3-rc2"
    echo
    exit
}

# check the command line parameters
if [ $# -eq 3 ]; then
    TAG=""
elif [ $# -eq 4 ]; then
    TAG="--branch=$4"
else
    usage
fi

if ! grep -q " $3 " <<< " prod dev "; then
    usage
fi

WHOLE_LIST="bampfa cinefiles pahma"
museum="$2"
if [[ ! $WHOLE_LIST =~ .*${museum}.* || "$museum" == "" ]]
then
  echo "2nd argument must be one of '${WHOLE_LIST}'"
  exit
fi

cd ~/projects || exit 1
RUN_DIR=$1
if [ -d ${RUN_DIR} ] ; then echo "$1 already exists... exiting" ; exit 1 ; fi

git -c advice.detachedHead=false clone ${TAG} https://github.com/cspace-deployment/radiance.git ${RUN_DIR}
cd ${RUN_DIR}/portal/
echo ; echo "deploying `git describe --always`" ; echo
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
# bundle config set deployment 'false'
bundle update

# install ucb customizations
cd ..
rm -rf common_tmp
cp -r extras/common common_tmp
perl -i -pe "s/#TENANT#/${museum}/g" `find common_tmp -type f`
rsync -av common_tmp/ ~/projects/${RUN_DIR}/portal/
rm -rf common_tmp
rsync -av extras/${museum}/ ~/projects/${RUN_DIR}/portal/

# complete configuration depending on environment (dev or prod)
./relink.sh ${RUN_DIR} ${museum} "$3"

# migrations and secrets are applied by relink.sh, or you can do them by hand
echo "deployed tag ${TAG} to ${RUN_DIR}, environment is $3"
echo "Restarting portal, you can too! enter: cd ~/projects/${RUN_DIR}/portal/ ; rake restart."
echo "Or just restart Apache"

cd ~/projects/${RUN_DIR}/portal/
rake restart
