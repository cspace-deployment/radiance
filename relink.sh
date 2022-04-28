#!/usr/bin/env bash

# nb: this script ONLY works on servers configured in the specific way
# that RTL servers are configured!
# i.e. code and deployment dirs in ~/projects, logs and dbs in /var, etc.

set -e

cd ~/projects || exit 1

function usage() {
    echo
    echo "    Usage: $0 install_dir museum prod|dev|local"
    echo
    echo "    e.g.   $0 202204221021.pahma pahma prod"
    echo
    exit 1
}

if [ $# -ne 3 ]; then
    usage
fi

if ! grep -q " $3 " <<< " prod dev local"; then
    usage
fi

INSTALL_DIR=$1/portal

if [[ ! -d /var/cspace/$2/db ]]; then
  # running on rtl server
  BLACKLIGHT_DIR=/var/cspace
elif [[ ! -f /cspace/blacklight/$2/db ]]; then
  # running on aws
  BLACKLIGHT_DIR=/cspace/blacklight
else
  # local deployment
  BLACKLIGHT_DIR=~
fi

if [ ! -d ${INSTALL_DIR} ] ; then
  echo "${INSTALL_DIR} does not exist... exiting"
  exit 1
fi

if [ "$3" == "prod" ]; then
  if [ ! -d "$1" ]; then
    echo "$HOME/projects/$1 does not exist. can't make a symlink to it. exiting."
    exit 1
  fi

  if [[ ! -f ${BLACKLIGHT_DIR}/$2/db/production.sqlite3 ]]; then
    echo "${BLACKLIGHT_DIR}/$2/db/production.sqlite3 not found."
    echo "so '$2' is not an existing deployment. please set up credentials, db dir (with migrations), and log dir"
    exit 1
  fi

  LINK_DIR=search_$2
  if [ -d ${LINK_DIR} ] && [ ! -L ${LINK_DIR} ] ; then echo "${LINK_DIR} exists and is not a symlink ... cowardly refusal to rm it and relink it" ; exit 1 ; fi
  rm ${LINK_DIR}
  ln -s ${INSTALL_DIR} ${LINK_DIR}
  echo "remaking links to db and log for production deployment"
  cd ${INSTALL_DIR}
  # link the log dir to the "permanent" log dir
  rm -rf log/
  ln -s ${BLACKLIGHT_DIR}/$2/log log
  # link the db directory to the "permanent" db directory
  rm -rf db/
  ln -s ${BLACKLIGHT_DIR}/$2/db db

  echo "copying existing credentials; they better be there!"
  # nb: yes we are overwriting any existing config/credentials.yml.enc
  cp ~/projects/credentials/credentials.yml.enc config/credentials.yml.enc
  # TODO: once blacklight (or rails?) renames this file, we can do it too
  cp ~/projects/credentials/master.key config/master.key

  # now we could apply migrations to the newly linked db
  # but we haven't figured out how to apply any new migrations so we skip this step and
  # just pray that the app continues to work with the existing models...
  # rails db:migrate RAILS_ENV=production
  echo "relinking done and credentials set. now restart apache..."
else
  echo "leaving db and log as is for dev deployment:"
  echo "1. regenerationg credentials:"
  echo
  cd ${INSTALL_DIR}
  rm -f config/credentials.yml.enc
  rm -f config/master.key
  EDITOR=cat rails credentials:edit
  echo
  echo "2. applying dev migrations:"
  echo
  bin/rails db:migrate RAILS_ENV=development
  echo
  # dev deployments also get symlinks; local deploys do not
  if [ "$3" == "dev" ]; then
    echo "3. make symlinks:"
    echo
    LINK_DIR=search_$2
    if [ -d ${LINK_DIR} ] && [ ! -L ${LINK_DIR} ] ; then echo "${LINK_DIR} exists and is not a symlink ... cowardly refusal to rm it and relink it" ; exit 1 ; fi
    rm ${LINK_DIR}
    ln -s ${INSTALL_DIR} ${LINK_DIR}
  fi
  echo
  echo "done with $3 install..."
  echo
  echo "ps: to start the development server, enter the following in the ${INSTALL_DIR} directory"
  echo "bin/rails s"
  echo
fi
