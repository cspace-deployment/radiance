### Customizations to Blacklight for UC Berkeley Museums

This repo contains a customized Blacklight application.

Blacklight is a Ruby on Rails application. Refer to the
Blacklight project documention for details about how to maintain and
deploy applicationd of this sort:

http://projectblacklight.org/

#### Ruby version

2.4.1  (at this moment; might work with other versions.)

#### System dependencies and configuration

See Blacklight instructions.

#### Database creation and initialization

Uses sqlite3.

The usual "rake db:migrate" options work.

#### How to run the test suite

Dunno. Just like Blacklight, I think!

#### External services needed

Requires access to the UCB Museum Solr search engines, so you must
be inside the UCB firewall to run the app.

See portal/config/blacklight.yml

#### Deployment instructions

###### For local development

All source code is in the RoR app directory "portal".

SO:

```
git clone https://github.com/cspace-deployment/radiance.git
cd portal/
bundle update
bundle install
bin/rails db:migrate RAILS_ENV=development
rails s
```

Then visit:

http://localhost:3000

You should see the start page.


###### on RTL servers

There are two scripts for use in making Dev and Prod
deployments on RTL servers.

`deploy.sh` - clones the GitHub repo and configures the specified deployment

`relink.sh` - switches the symlink to the specified directory

On RTL servers, it is assumed that a directory `projects` exists in the home directory
of the user running the application.

The RoR code is deployed and configured into this directory.

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

Then you can deploy and start up the application:

E.g.
```
./deploy.sh s20190305 production 2.0.0
```

which clones the code, and sets up a production deployment

Then, to actually start using the new deployment:

```
./relink.sh s20190305 pahma production
```

... then restart Apache2.

NB:

* you can use `relink.sh` to point Passenger to any existing deployment in `~/projects`.
This is useful in testing new deployments while keeping old ones around.

* both of these script make assumptions about the RTL servers
in use...!
