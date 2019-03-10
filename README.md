### Customizations to Blacklight for UC Berkeley Museums

[![build status](https://travis-ci.com/cspace-deployment/radiance.svg?branch=master)](https://travis-ci.com/cspace-deployment/radiance)[![Coverage Status](https://coveralls.io/repos/github/cspace-deployment/radiance/badge.svg?branch=master)](https://coveralls.io/github/cspace-deployment/radiance?branch=master)

This repo contains a customized Blacklight application.

Blacklight is a Ruby on Rails application. Refer to the
Blacklight project documention for details about how to maintain and
deploy applications of this sort:

http://projectblacklight.org/


**_Ops folks: for RTL specific deployment info, click [here](#deploying-on-rtl-servers)._**

#### Ruby version

2.4.1  (at this moment; might work with other versions.)

#### System dependencies and configuration

First, you must have have installed all the RoR prerequisites (and if using a local Solr server which you should
for testing, those prerequisites, too). Probably it is easiest to first
install and run a "vanilla" Blacklight deployment, then try the `radiance` code described below.

See the Blacklight documentation:

https://github.com/projectblacklight/blacklight/wiki/Quickstart

#### Database creation and initialization

Uses sqlite3.

The usual "rake db:migrate" options work.

#### How to run the test suite

Dunno. Just like Blacklight, I think!

#### External services needed

Requires access to the UCB Museum Solr search engines, so you must
be inside the UCB firewall to run the app.

See portal/config/blacklight.yml for details on pointing to Solr servers.

#### Deployment instructions

##### For local development

All source code is in the RoR app directory called "portal".

SO:

```
git clone https://github.com/cspace-deployment/radiance.git
cd radiance/portal/
bundle update
bundle install
bin/rails db:migrate RAILS_ENV=development
rails s
```

Then visit:

http://localhost:3000

You should see the start page.

##### Deploying on RTL servers

*Caveat lector...these instructions are still quite raw, as is the deployment process itself. Suggestions welcome!*

A few important details, but do please read this whole section before you attempt to deploy on RTL servers:

* The actual recipe for a quick and painless deploment may be found [further below](#deploying-new-versions-on-rtl-servers). But do read on for the gory details.
* It is expected that a "release document" has been prepared in advance for any particular release, and a "deployment JIRA" exists as well. Please do check for these before attempting to deploy a new version!
* Blacklight is deployed under Passenger on RTL servers, and currently expects the deployed code to be in a particular subdirectory in `~blacklight/projects`.  The application also runs under user `blacklight`.
* The instructions below assume that you have followed the [initial instructions](#initial-setup-for-deployments-on-rtl-servers) (below) to set up the deployment scripts from the `radiance` repo. Once the scripts are set up (copied) the clone of the `radiance` repo can be removed. 
* However, you should check to ensure that you have the latest versions of these scripts before deploying. Catch-22, sorry!
* The convention is to deploy into a subdirectory of `~projects` using a name of the form "sYYYYMMDD". This allows us to keep track of the versions that have been deployed and to roll back to an earlier version if necessary.
* But note that in cases of `production` deployments, all deployments symlink to the same `db` and `log` directories in `/var`. This is an important consideration for db migrations and rollbacks: you may need to undo migrations in the case of a rollback. Consider whether a backup is necessary beforehand.
* A `production` deployment means to create the production environment, both in the sense of RoR as well as in the sense of the RTL servers. A `development` deployment makes an Ror development deploy and does *not* symlink the `log` and `db` directories. In the case of a `development` deployment, the db migrations are performed, and the both the logs and database are created fresh and clean.

###### Initial setup for deployments on RTL servers

If you haven't already done so, clone the [radiance](https://github.com/cspace-deployment/radiance) repo and set up the helper scripts:

```
ssh blacklight-prod.ets.berkeley.edu

sudo su - blacklight
cd ~/projects

# only do this if it hasn't been done already...
git clone https://github.com/cspace-deployment/radiance.git 
cp radiance/*.sh .
```

There are two helper scripts for use in making Dev and Prod
deployments on RTL servers.

`deploy.sh` - clones the GitHub repo and configures the specified deployment.

`relink.sh` - switches the symlink to the specified directory.

For initial setup, you'll need to:

* Have Ruby 2.4.1 installed.
* Have Apache configured appropriately (e.g. Passenger, etc.)
* Have a `SECRET_KEY_BASE` environment variable set (see the Blacklight docs for details).

E.g.

```
$ ssh blacklight-dev.ets.berkeley.edu

[...]

Last login: Tue Mar  5 10:54:19 2019 from 128.32.202.5
jblowe@blacklight-dev:~$ sudo su - blacklight

blacklight@blacklight-dev:~$ printenv | grep SECRET_KEY
SECRET_KEY_BASE=xxxxxxxxx......xxxxxxx
```

Then you can deploy and start up the application.

###### Deploying new versions on RTL servers

On the RTL servers, you may assume that the two helper scripts have
been set up in `~/projects` and are ready to use. In theory, only these two scripts are needed
to do a complete deployment.

HOWEVER, if the deployment you are doing is not a standard, vanilla deployment of a new minor version, you may need to consider performing the steps in the scripts yourself, by hand.

E.g.
```
./deploy.sh s20190305 production 2.0.0
```

which clones the code, and sets up a production deployment.

Then, to actually start using the new deployment:

```
./relink.sh s20190305 pahma production
```

... then restart Apache2.

NB:

* The "production" option on the `relink.sh` script also symlinks the Rails `db` and `log`
directories to persistent directories in `/var`. The "development" option leaves those
directories alone. This should be taken into consideration if migrations
are actually necessary: the production option does not perform any migrations.

* You can use `relink.sh` to point Passenger to any existing deployment in `~/projects`.
This is useful in testing new deployments while keeping old ones around.

* Both of these script make assumptions about the RTL servers
in use...!

Here's a recipe for actually deploying a new version on an RTL server:

1. Sign in to blacklight server (dev or prod)
1. Stop Apache
1. sudo to the blacklight user
1. Deploy the new version
1. Exit the blacklight shell
1. Start Apache
1. Verify in a browser that the application works

Here's a possible monologue:

```
ssh blacklight-dev.ets.berkeley.edu

sudo apache2ctl stop

sudo su - blacklight
cd ~/projects

# use the two helper scripts to get and configure the new version
./deploy.sh s20190308 production 2.0.1
./relink.sh s20190308 pahma production
 
exit

sudo apache2ctl start
exit
```
###### Rolling back on RTL servers

In theory, rolling back is merely a matter of changing the symlink back to a previous directory. But careful about database migrations and other possible dependencies.

```
# to roll back

# stop apache
cd ~/projects
# remove symlink
rm search_pahma
# remake symlink
ln -s s20180305/portal search_pahma
# now start apache
```

##### Google Analytics and robots.txt

Google Analytics ("UA") is automatically enabled for production deployments. See e.g.

`blacklight.html.erb` (where the tracking ID is hardcoded)

and

`app/assets/javascripts/google_analytics.js.coffee`

Yes, it is a bit complicated to get UA working in a Rails 5 app!

By default, `public/robots.txt` block _all_ crawlers. For deployments where you want to admit
crawlers (e.g. production deployments) you may wish to change this. See, e.g.:

https://issues.collectionspace.org/browse/DJAN-98

You may wish to preserve the `robots.txt` that was being used already.

To allow all comers, simply remove the file.
