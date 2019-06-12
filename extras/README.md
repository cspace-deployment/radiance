### Customizations to Blacklight for UC Berkeley Museums

This directory contains code to tweak the "standard" UCB blacklight code (for PAHMA)
so that it works with the Solr cores for the other UCB museums.

The tweaks rely on the existing configuration used for the Django webapp portals, contained
in the django_example_config directory.

Note that the generation of the BL configuration based on the Django webapp config
is not perfect: you may want to or need to update the catalog controller by hand.
In such cases, it might be wise to simply save the new, improved versions of code
in this `extras` directory; the install script (`install_ucb.sh`) has some provisions for overlaying
such additional customizations -- read the script for details.

The process is as follows:

1. Deploy the BL RoR app as usual using the `deploy.sh` and `relink.sh` scripts.
1. Apply the tweaks for a tenant to the deployed code using the `install_ucb.sh` script
1. Start Rails the usual way.

#### Suggested procedure, still wet behind the ears

```bash
# deploy the "standard" blacklight ucb deployment to tenant dir (in this case, ucjeps)
./deploy.sh ucjeps production
cd ~/projects/ucjeps/portal/

# have to complete the migration by hand for the moment
bin/rails db:migrate RAILS_ENV=development

# now customize for ucjeps
./install_ucb.sh ucjeps
~/PycharmProjects/django_example_config/ucjeps/config/ucjepspublicparms.csv

# might need to tweak the generated code: reorder fields, etc.
vi app/controllers/catalog_controller.rb 
rails s
```