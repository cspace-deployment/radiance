#!/bin/bash

if [ $# -ne 1 ]; then
    echo
    echo "    Usage: $0 museum"
    echo
    echo "    e.g.   $0 pahma"
    echo
    echo "    (only works on RTL Ubuntu servers!)"
    exit
fi

TENANT=$1

cd ~/projects/radiance/

# tidy up repo
git clean -fd
git reset --hard

git checkout main
git pull -v

# copy the needed files
cp extras/${TENANT}_splash.html.erb ~/projects/search_${TENANT}/app/views/shared/_splash.html.erb 
cp portal/public/*.jpg ~/projects/search_${TENANT}/public/
cp portal/public/*.png ~/projects/search_${TENANT}/public/

# restart blacklight for ${TENANT}
touch ~/projects/search_${TENANT}/tmp/restart.txt
