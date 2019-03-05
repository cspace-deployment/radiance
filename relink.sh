#!/usr/bin/env bash

# nb: this script ONLY works on RTL servers configured the way they are configured!
# i.e. code and deployment dirs in ~/projects, logs and dbs in /var, etc.

set -e

cd ~/projects

if [ $# -ne 3 ]; then
    echo
    echo "    Usage: $0 install_dir link_dir production|development"
    echo
    echo "    e.g.   $0 s20190305 pahma prod"
    echo
    exit
fi

if ! grep -q " $3 " <<< " production development "; then
    echo
    echo "    Usage: $0 install_dir link_dir production|development"
    echo
    echo "    e.g.   $0 s20190305 pahma production"
    echo
    exit
fi

RUN_DIR=$1/portal
if [ ! -d ${RUN_DIR} ] ; then echo "$1 does not exist... exiting" ; exit 1 ; fi
if [ -d search_$2 -a ! -L search_$2 ] ; then echo "search_$2 exists and is not a symlink ... cowardly refusal to rm it and relink it" ; exit 1 ; fi
rm -f search_$2
ln -s ${RUN_DIR} search_$2
if [ "$3" == "production" ]; then
  echo "remaking links to db and log for production deployment"
  cd ${RUN_DIR}
  # link the log dir to the "permanent" log dir
  rm -rf log/
  ln -s /var/log/blacklight/$2 log
  # link the db directory to the "permanent" db directory
  rm -rf db/
  ln -s /var/blacklight-db/$2 db
  export RAILS_ENV=production
  rake db:migrate
else
  echo "leaving db and log as is for dev deployment"
  cd ${RUN_DIR}
  # nb: right now, only the production migration works, for some reason...
  export RAILS_ENV=development
  rake db:migrate
fi
echo relinking and migrating done. now restart apache...
