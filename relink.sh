#!/usr/bin/env bash

# nb: this script ONLY works on servers configured in the specific way
# that RTL servers are configured!
# i.e. code and deployment dirs in ~/projects, logs and dbs in /var, etc.

set -e

cd ~/projects

function usage() {
    echo
    echo "    Usage: $0 install_dir museum production|development"
    echo
    echo "    e.g.   $0 20200305.pahma pahma production"
    echo
    exit
}

if [ $# -ne 3 ]; then
    usage
fi

if ! grep -q " $3 " <<< " production development "; then
    usage
fi

INSTALL_DIR=$1/portal

if [ "$3" == "production" ]; then
  LINK_DIR=search_$2
  if [ ! -d ${INSTALL_DIR} ] ; then echo "${INSTALL_DIR} does not exist... exiting" ; exit 1 ; fi
  if [ -d ${LINK_DIR} -a ! -L ${LINK_DIR} ] ; then echo "${LINK_DIR} exists and is not a symlink ... cowardly refusal to rm it and relink it" ; exit 1 ; fi
  rm ${LINK_DIR}
  ln -s ${INSTALL_DIR} ${LINK_DIR}
  echo "remaking links to db and log for production deployment"
  cd ${INSTALL_DIR}
  # link the log dir to the "permanent" log dir
  rm -rf log/
  ln -s /var/cspace/$2/blacklight/log log
  # link the db directory to the "permanent" db directory
  rm -rf db/
  ln -s /var/cspace/$2/blacklight/db db

  echo "copying existing credentials; they better be there!"
  # nb: yes we are overwriting any existing config/credentials.yml.enc
  cp ~/projects/credentials/credentials.yml.enc config/credentials.yml.enc
  cp ~/projects/credentials/master.key config/master.key

  # now we could apply migrations to the newly linked db
  # but we haven't figured out how to apply any new migrations so we skip this step and
  # just pray that the app continues to work with the existing models...
  # rails db:migrate RAILS_ENV=production
  echo "relinking done and credentials set. now restart apache..."
else
  echo "leaving db and log as is for dev deployment, regenerating credentials, and applying dev migrations"
  echo "nb: when asked to edit credentials, you can just :q, unless you want to edit them after all"
  cd ${INSTALL_DIR}
  # this seems to be necessary for rails 5.2
  # rm -f config/credentials.yml.enc
  # rm -f config/master.key
  # EDITOR=vi rails credentials:edit
  rails db:migrate RAILS_ENV=development
  echo "relinking and migrating done..."
fi
