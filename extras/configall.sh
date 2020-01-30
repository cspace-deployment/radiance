#!/usr/bin/env bash
# I think this only works on AWS...
cd ~/projects/bampfa    ; ./install_ucb.sh bampfa    ~/projects/cspace-webapps-ucb/bampfa/config/public_collection_info.csv
cd ~/projects/botgarden ; ./install_ucb.sh botgarden ~/projects/cspace-webapps-ucb/botgarden/config/plantinfo.csv
cd ~/projects/cinefiles ; ./install_ucb.sh cinefiles ~/projects/cspace-webapps-ucb/cinefiles/config/public_collection_info.csv
#cd ~/projects/pahma     ; ./install_ucb.sh pahma     ~/projects/cspace-webapps-ucb/pahma/config/pahmapublicparms.csv
cd ~/projects/ucjeps    ; ./install_ucb.sh ucjeps    ~/projects/cspace-webapps-ucb/ucjeps/config/ucjepspublicparms.csv
