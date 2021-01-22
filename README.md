### Customizations to Blacklight for UC Berkeley Museums

[![build status](https://travis-ci.com/cspace-deployment/radiance.svg?branch=master)](https://travis-ci.com/cspace-deployment/radiance)[![Coverage Status](https://coveralls.io/repos/github/cspace-deployment/radiance/badge.svg?branch=master)](https://coveralls.io/github/cspace-deployment/radiance?branch=master)

This repo contains a customized Blacklight application.

Blacklight is a Ruby on Rails application. Refer to the
Blacklight project documention for details about how to maintain and
deploy applications of this sort:

http://projectblacklight.org/


**_Ops folks: for RTL specific deployment info, click [here](#deploying-on-rtl-servers)._**

#### Ruby and Rails versions

Ruby 2.6.6\
Rails 5.2.4.4

To check:

```bash
blacklight@blacklight-dev:~/projects/20200226/portal$ ruby -v
ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-linux]uby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux-gnu]
blacklight@blacklight-dev:~/projects/20200226/portal$ rails -v
Rails 5.2.4.4
```

#### System dependencies and configuration

First, you must have have installed all the RoR prerequisites (and if using a local Solr server which you should
for testing, those prerequisites, too). Probably it is easiest to first
install and run a "vanilla" Blacklight deployment, then try the `radiance` code described below.

See the Blacklight documentation:

https://github.com/projectblacklight/blacklight/wiki/Quickstart

#### Database creation and initialization

Uses sqlite3.

The usual "`rake db:migrate`" options work.

#### How to run the test suite

Dunno. Just like Blacklight, I think!

#### External services needed

Requires access to one of the UCB Museum Solr search
engines, so one of the following much be true.

You must:

* use the production Solr server at webapps.cspace.berkeley.edu
* **be inside the UCB firewall to run the app using the Dev solr server**
* have your own Solr server configured and running.

See `portal/config/blacklight.yml` for details on pointing to Solr servers, and
read up further below.

#### Deployment instructions

##### For local development, quick start

All source code is in the RoR app directory called "portal".

Steps needed:

* clone the repo
* install the customizations for the museum you are working on
* if desired, point to one of the existing Solr servers (or use your own)
* bundle update, bundle install
* create the credentials
* do the migration
* start rails

(This will install the PAHMA version of the Blacklight Portal...)

SO:

```
git clone https://github.com/cspace-deployment/radiance.git
cd radiance
# optional: customize for a particular museum
./install_ucb.sh pahma
cd radiance/portal/
# optional: configure a non-localhost solr server
vi config/blacklight.yml
bundle update
bundle install
# just say ":q" when in vi, and the credentials will get saved...
EDITOR=vi bin/rails credentials:edit
bin/rails db:migrate RAILS_ENV=development

rails s
```

NB: the Solr resource by default is localhost. Unless you have a suitable Solr server
set up on your local system, you'll need to edit `config/blacklight.yml` to use
one of the existing public cores, e.g.

[https://webapps.cspace.berkeley.edu/solr/pahma-public/select](https://webapps.cspace.berkeley.edu/solr/pahma-public/select?q=*:*&rows=10)

_To access the Dev service, your application must be running within the UCB firewall,
e.g. using the VPN. If you have Solr installed
locally (and eventually, you should!) configure it in config/blacklight.yml._

Then visit:

http://localhost:3000

You should see the start page.

##### Deploying on RTL servers

*Caveat lector...these instructions are still a bit raw, as is the deployment process itself. Suggestions welcome!*

A few important details, but do please read this whole section before you attempt to deploy on RTL servers:

* The actual recipe for a quick and painless deployment may be found [further below](#deploying-new-versions-on-rtl-servers). But do read on for the gory details.
* It is expected that a "release document" has been prepared in advance for any particular release, and a "deployment JIRA" exists as well. Please do check for these before attempting to deploy a new version!
* This Blacklight app expected to deployed as user `blacklight` under Passenger on RTL servers, and currently expects the deployed code to be in a particular subdirectory in `~blacklight/projects`.  The application also *runs* under user `blacklight`.
* However, you should check to ensure that you have the latest versions of these scripts before deploying.
* The convention is to deploy into a subdirectory of `~/projects` using a name of the form "YYYYMMDD.museum". This allows us to keep track of the versions that have been deployed and to roll back to an earlier version if necessary.
* But note that in cases of `production` deployments, all deployments symlink to the same `db` and `log` directories in `/var/cspace`. This is an important consideration for db migrations and rollbacks: you may need to undo migrations in the case of a rollback. Consider whether a backup is necessary beforehand.
* A `production` deployment means to create the production environment, both in the sense of RoR as well as in the sense of the RTL servers. A `development` deployment makes an Ror development deploy and does *not* symlink the `log` and `db` directories. In the case of a `development` deployment, the db migrations are performed, and the both the logs and database are created fresh and clean.
* Hope that's all clear!

###### Initial setup for deployments on RTL servers

If you haven't already done so, clone the [radiance](https://github.com/cspace-deployment/radiance) repo and set up the helper scripts:

```
ssh blacklight-prod.ets.berkeley.edu

sudo su - blacklight
cd ~/projects

# only do this if it hasn't been done already...
git clone https://github.com/cspace-deployment/radiance.git 

# otherwise, just bring it up to date
git pull -v
```

There are three helper scripts for use in making Dev and Prod
deployments on RTL servers.

`deploy.sh` - clones the GitHub repo and configures the specified deployment.

`relink.sh` - switches the symlink to the specified directory.

`install_ucb.sh` - installs museum specific customizations.

For initial setup, you'll need to:

* Have Ruby 2.5.1 or higher installed.
* Have Apache configured appropriately (e.g. Passenger, etc.)

E.g.

```
$ ssh blacklight-dev.ets.berkeley.edu

[...]

Last login: Tue Mar  5 10:54:19 2019 from 128.32.202.5
xxx@blacklight-dev:~$ sudo su - blacklight

ruby -v
ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux-gnu]
```

Then you can deploy and start up the application.

###### Updating versions on RTL servers

On the RTL servers, you may assume that the two helper scripts have
been set up in `~/projects` and are ready to use. In theory, only these two scripts are needed
to do a complete deployment/update.

To deploy and build the code from GitHub:
```
./deploy.sh 20200226.pahma production 2.0.9
./install_ucb.sh pahma
```

This clones the code into `~/projects/20200226.pahma`, sets up a production deployment of version 2.0.9,
and applies the PAHMA customizations.

To actually start *using* the new deployment, you'll need to
symlink the new directory to the runtime directory and
attend to a few other details. This can be done tidily as follows.

```
./relink.sh 20200226.pahma pahma production
```

NB:

* For development deployments, the `relink.sh` script trivially 'edits' the Rails credentials as required by the
new Rails 5.2 conventions (google e.g. "rails credentials:edit" to see what
the fuss is about). It uses `vi` and all one needs to do when one is
dumped into the editor is "`:q`" -- i.e. quit without saving -- and the right
thing will happen. I could not figure out how to make this happen without a manual
editing step. Perhaps a mightier Rails wizard than me will figure this
out someday.

* The "production" option on the `relink.sh` script symlinks the Rails `db` and `log`
directories to persistent directories in `/var`. The "development" option leaves those
directories alone in their pristine state. The need for migrations should be taken into consideration when
planning upgrades.

* By changing the symlinks you can point Passenger to any existing deployment in `~/projects`.
This is useful in testing new deployments while keeping old ones around.

* Both of these script make assumptions about the RTL Ubuntu servers
in use...!

Here's a recipe for actually deploying a new version on an RTL server:

1. Sign in to blacklight server (dev or prod)
1. Stop Apache
1. `sudo` to the `blacklight` user
1. Backup the sqllite3 database (optional)
1. Deploy the new version
1. Exit the blacklight shell
1. Start Apache
1. Verify in a browser that the application works

Here's a possible monologue:

```
ssh blacklight-dev.ets.berkeley.edu

sudo su - blacklight
cd ~/projects

# make a copy of the database just in case
cp /var/blacklight-db/search_pahma/* /tmp

# use the three helper scripts to get and configure the new version
./deploy.sh 20200415.pahma production 2.0.9
./install_ucb.sh pahma
./relink.sh 20200415.pahma pahma production
# in general, get rid of robots.txt for production deployments...
rm 20200415.pahma/portal/public/robots.txt
 
exit

sudo apache2ctl start

# check in browser that the app works...

# clean up
sudo su - blacklight
rm /tmp/production.sqllite3
rm ...

exit
```
###### Rolling back on RTL servers

In theory, rolling back is merely a matter of changing the symlink back to a previous directory. But careful about database migrations and other possible dependencies.

```
# to roll back

# stop apache? (might not be necessary...)
cd ~/projects
# remove symlink
rm search_pahma
# remake symlink to previous deployment directory
ln -s 20180305.pahma/portal search_pahma
# now start apache if you stopped it
```

But do consider whether you need to "unmigrate" the database. If so,
the best way is probably to copy the backup you made on top of what was there...

##### Google Analytics and robots.txt

Google Analytics ("UA") is automatically enabled for production deployments. See e.g.

`blacklight.html.erb` (where the tracking ID is hardcoded)

and

`app/assets/javascripts/google_analytics.js.coffee`

Yes, it is a bit complicated to get UA working in a Rails 5 app!

By default, `public/robots.txt` blocks _all_ crawlers. For deployments where you want to admit
crawlers (e.g. production deployments) you may wish to change this. See, e.g.:

https://issues.collectionspace.org/browse/DJAN-98

You may wish to preserve the `robots.txt` that was being used already.

To allow all comers, simply remove the file.
