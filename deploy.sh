set -e

if [ $# -eq 2 ]; then
    TAG=""
elif [ $# -eq 3 ]; then
    TAG="--branch=$3"
else
    echo
    echo "    Usage: $0 install_dir production|development <optional-version>"
    echo
    echo "    e.g.   $0 s20190305 production 2.0.0"
    echo
    exit
fi

if ! grep -q " $2 " <<< " production development "; then
    echo
    echo "    Usage: $0 install_dir production|development <optional-version>"
    echo
    echo "    e.g.   $0 s20190305 production 2.0.0"
    echo
    exit
fi

cd ~/projects
RUN_DIR=$1
if [ -d ${RUN_DIR} ] ; then echo "$1 already exists... exiting" ; exit 1 ; fi

git clone ${TAG} https://github.com/cspace-deployment/radiance.git ${RUN_DIR}
cd ${RUN_DIR}/portal/
bundle update
bundle install
bin/rails db:migrate RAILS_ENV=$2
