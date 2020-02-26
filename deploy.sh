set -e

if [ $# -eq 2 ]; then
    TAG=""
elif [ $# -eq 3 ]; then
    TAG="--branch=$3"
else
    echo
    echo "    Usage: $0 install_dir production|development <optional-version>"
    echo
    echo "    e.g.   $0 20190305 production 2.0.3"
    echo
    exit
fi

if ! grep -q " $2 " <<< " production development "; then
    echo
    echo "    Usage: $0 install_dir production|development <optional-version>"
    echo
    echo "    e.g.   $0 20190305 production 2.0.3"
    echo
    exit
fi

cd ~/projects
RUN_DIR=$1
if [ -d ${RUN_DIR} ] ; then echo "$1 already exists... exiting" ; exit 1 ; fi

git clone ${TAG} https://github.com/cspace-deployment/radiance.git ${RUN_DIR}
cd ${RUN_DIR}/portal/
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
bundle install --deployment

# this seems to be necessary for rails 5.2
rm -f config/credentials.yml.enc
rm -f config/master.key
# EDITOR=vi rails credentials:edit

# migrations are applied by relink.sh
# rails db:migrate RAILS_ENV=$2
echo "deployed tag ${TAG} to ${RUN_DIR}, environment is $2"
echo "for deployment on RTL servers, execute:"
echo "./relink.sh ${RUN_DIR} pahma $2"
echo "then restart Apache, or (re)start some other server."
