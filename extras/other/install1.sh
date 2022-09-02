cd ~/projects
./deploy.sh $1 development
cd $1/portal
rm Gemfile.lock 
bundle update --bundler
bundle install
bin/rails db:migrate RAILS_ENV=development
