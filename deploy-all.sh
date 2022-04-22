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

YYYYMMDDHHMM=`date +%Y%m%d%H%M`

# update radiance repo
cd ${HOME}/projects/radiance
git checkout main
git pull -v

cd ${HOME}/projects

# redeploy both
radiance/deploy.sh ${YYYYMMDDHHMM}.pahma $2 $1 &
radiance/deploy.sh ${YYYYMMDDHHMM}.cinefiles $2 $1 &
radiance/deploy.sh ${YYYYMMDDHHMM}.bampfa $2 $1 &
wait

# relink both
radiance/relink.sh ${YYYYMMDDHHMM}.pahma pahma $2
radiance/relink.sh ${YYYYMMDDHHMM}.cinefiles cinefiles $2
radiance/relink.sh ${YYYYMMDDHHMM}.bampfa bampfa $2

cd ${HOME}/projects/${YYYYMMDDHHMM}.pahma
./install_ucb.sh pahma

# apply customizations
cd ${HOME}/projects/${YYYYMMDDHHMM}.cinefiles
./install_ucb.sh cinefiles

cd ${HOME}/projects/${YYYYMMDDHHMM}.bampfa
# TODO: bampfa install should be its own thing, not piggyback on cinefiles
./install_ucb.sh cinefiles
./make-bampfa-demo.sh
