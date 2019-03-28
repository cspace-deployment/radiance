#!/usr/bin/env bash

# nb: this script ONLY works on servers configured in the specific way
# that RTL servers are configured!
# i.e. code and deployment dirs in ~/projects, logs and dbs in /var, etc.

set -e

cd ~/projects

if [ $# -ne 3 ]; then
    echo
    echo "    Usage: $0 install_dir link_dir production|development"
    echo
    echo "    e.g.   $0 s20190305 search_pahma production"
    echo
    exit
fi

if ! grep -q " $3 " <<< " production development "; then
    echo
    echo "    Usage: $0 install_dir link_dir production|development"
    echo
    echo "    e.g.   $0 s20190305 search_pahma production"
    echo
    exit
fi

INSTALL_DIR=$1/portal
LINK_DIR=$2
if [ ! -d ${INSTALL_DIR} ] ; then echo "$1 does not exist... exiting" ; exit 1 ; fi
if [ -d ${LINK_DIR} -a ! -L ${LINK_DIR} ] ; then echo "${LINK_DIR} exists and is not a symlink ... cowardly refusal to rm it and relink it" ; exit 1 ; fi
rm ${LINK_DIR}
ln -s ${INSTALL_DIR} ${LINK_DIR}
if [ "$3" == "production" ]; then
  echo "remaking links to db and log for production deployment"
  cd ${INSTALL_DIR}
  # link the log dir to the "permanent" log dir
  rm -rf log/
  ln -s /var/log/blacklight/${LINK_DIR} log
  # link the db directory to the "permanent" db directory
  rm -rf db/
  ln -s /var/blacklight-db/${LINK_DIR} db
  # now we can apply migrations to the newly linked db
  bin/rails db:migrate RAILS_ENV=production
else
  echo "leaving db and log as is for dev deployment (migrations applied by deploy.sh)"
  cd ${INSTALL_DIR}
  export RAILS_ENV=development
fi
echo relinking and migrating done. now restart apache...
