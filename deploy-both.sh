#!/bin/bash

# lil helper script to deploy both cinefiles and pahma blacklight apps

function usage() {
    echo
    echo "    Usage: $0 version production|development"
    echo
    echo "    e.g.   $0 2.0.10-rc2 production"
    echo
    exit
}

if [ $# -ne 2 ]; then
    usage
fi

if ! grep -q " $2 " <<< " production development "; then
    usage
fi

YYMMDD=`date +%y%m%d`

# update radiance repo
cd ~/projects/radiance
git checkout main
git pull -v

cd ~/projects

# redeploy both
radiance/deploy.sh ${YYMMDD}.pahma $2 $1
radiance/deploy.sh ${YYMMDD}.cinefiles $2 $1

# relink both
radiance/relink.sh ${YYMMDD}.pahma pahma $2
radiance/relink.sh ${YYMMDD}.cinefiles cinefiles $2

# apply customizations
cd ~/projects/${YYMMDD}.cinefiles
./install_ucb.sh cinefiles

cd ~/projects/${YYMMDD}.pahma
./install_ucb.sh pahma
