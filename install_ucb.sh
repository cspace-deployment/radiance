#!/usr/bin/env bash
#set -e
#set -x
tenant=$1
current_directory=`pwd`
extra_dir="${current_directory}/extras"

WHOLE_LIST="bampfa botgarden cinefiles pahma ucjeps"

if [ ! -d portal ]; then
  echo "Can't find 'portal' directory. Please verify name and location"
  echo "This script must be executed from the base dir of the ucb blacklight customizations (i.e. radiance)"
  echo "$0 tenant"
  exit
fi

cd portal || exit

# check the command line parameters

if [[ ! $WHOLE_LIST =~ .*${tenant}.* || "$tenant" == "" ]]
then
  echo "1st argument must be one of '${WHOLE_LIST}'"
  echo "$0 tenant"
  exit
fi

if [ ! -d "${extra_dir}" ]; then
  echo "Can't find directory '${extra_dir}'. Please verify name and location"
  echo "This script must be executed from the base dir of the ucb blacklight customization (i.e. radiance)"
  echo "$0 tenant"
  exit
fi

echo "Installing ${tenant} from ${extra_dir}..."
echo

# 'customize' the code in the extras directory
cp -r ${extra_dir} ${extra_dir}_tmp
# perl -i -pe "s/#TENANT#/${tenant}/g" ${extra_dir}_tmp/* 2>&1
for f in $(find ${extra_dir}_tmp); do [[ -f $f ]] && perl -i -pe "s/#TENANT#/${tenant}/g" $f 2>&1; done

rm -rf app/*
cp -rv ${extra_dir}_tmp/common/app/ app

cp -v config/credentials.yml.enc ${extra_dir}_tmp/common/config
cp -v config/master.key ${extra_dir}_tmp/common/config
rm -rf config/*
cp -rv ${extra_dir}_tmp/common/config/ config

rm -rf lib/*
cp -rv ${extra_dir}_tmp/common/lib/ lib

rm -rf public/*
cp -rv ${extra_dir}_tmp/common/public/ public

# now apply customizations, if any
cp -rv ${extra_dir}_tmp/${tenant}/app/ app
cp -rv ${extra_dir}_tmp/${tenant}/config/ config
cp -rv ${extra_dir}_tmp/${tenant}/lib/ lib
cp -rv ${extra_dir}_tmp/${tenant}/public/ public

# get rid of the working directory, etc.
rm -f app/assets/stylesheets/normalize.min.css
rm -rf ${extra_dir}_tmp
