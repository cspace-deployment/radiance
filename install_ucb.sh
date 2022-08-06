#!/usr/bin/env bash
#set -e
#set -x
tenant=$1
current_directory=`pwd`
extra_dir="../extras"

WHOLE_LIST="bampfa botgarden cinefiles pahma ucjeps"

if [ ! -d portal ]; then
  echo "Can't find 'portal' directory. Please verify name and location"
  echo "This script must be executed from the base dir of the ucb blacklight customizations (i.e. radiance)"
  echo "$0 tenant"
  exit
fi

cd portal || exit

# check the command line parameters

if [[ ! $WHOLE_LIST =~ .*${tenant}.* || "$tenant" == "" ]]
then
  echo "1st argument must be one of '${WHOLE_LIST}'"
  echo "$0 tenant"
  exit
fi

if [ ! -d "${extra_dir}" ]; then
  echo "Can't find directory '${extra_dir}'. Please verify name and location"
  echo "This script must be executed from the base dir of the ucb blacklight customization (i.e. radiance)"
  echo "$0 tenant"
  exit
fi

# 'customize' the code in the extras directory
cp -r ${extra_dir} ${extra_dir}_tmp
perl -i -pe "s/#TENANT#/${tenant}/g" ${extra_dir}_tmp/* 2>&1

# now apply customizations, if any

# nb: the header logos for all ucb tenants are already in the public static directory
mkdir app/views/shared

# copy a favicon
# right now we only have PNG favicons...
#cp ${extra_dir}_tmp/${tenant}_favicon.ico app/assets/images/favicon.ico
cp ${extra_dir}_tmp/cspace_fav.png app/assets/images/favicon.png
cp ${extra_dir}_tmp/${tenant}_favicon.png app/assets/images/favicon.png

# generic helpers and config, but some do need to be configured per-tenant
cp ${extra_dir}_tmp/application.rb config/application.rb
cp ${extra_dir}_tmp/application_helper.rb app/helpers
cp ${extra_dir}_tmp/thumbnail_presenter.rb app/presenters/blacklight/thumbnail_presenter.rb
cp ${extra_dir}_tmp/routes.rb config/routes.rb
####cp ${extra_dir}_tmp/catalog_helper_behavior.rb app/helpers/blacklight
cp ${extra_dir}_tmp/blacklight.yml config
cp ${extra_dir}_tmp/blacklight.en.yml config/locales
#
cp ${extra_dir}_tmp/${tenant}_production.rb config/environments/production.rb
cp ${extra_dir}_tmp/${tenant}_blacklight.en.yml config/locales/blacklight.en.yml
#
## use our generic header, footer, etc. partials
cp ${extra_dir}_tmp/_header_navbar.html.erb app/views/shared/
cp ${extra_dir}_tmp/_pdfs.html.erb app/views/shared/
cp ${extra_dir}_tmp/_footer.html.erb app/views/shared/
cp ${extra_dir}_tmp/_splash.html.erb app/views/shared/
cp ${extra_dir}_tmp/_home_text.html.erb app/views/shared/
cp ${extra_dir}_tmp/_search_form.html.erb app/views/shared/
#
## possible customized partials
##cp ${extra_dir}_tmp/_user_util_links.html.erb app/views/
cp ${extra_dir}_tmp/${tenant}_user_util_links.html.erb app/views/_user_util_links.html.erb
cp ${extra_dir}_tmp/${tenant}_catalog_controller.rb app/controllers/catalog_controller.rb
cp ${extra_dir}_tmp/${tenant}_header_navbar.html.erb app/views/shared/_header_navbar.html.erb
cp ${extra_dir}_tmp/${tenant}_footer.html.erb app/views/shared/_footer.html.erb

#cp ${extra_dir}_tmp/${tenant}_home_text.html.erb app/views/catalog/_home_text.html.erb
#cp ${extra_dir}_tmp/${tenant}_blacklight.html.erb app/views/layouts/blacklight/base.html.erb
# splash page goes into _home_text_html.erb for now
mkdir app/views/catalog && cp ${extra_dir}_tmp/${tenant}_splash.html.erb app/views/catalog/_home_text.html.erb

cp ${extra_dir}_tmp/${tenant}_search_form.html.erb app/views/shared/_search_form.html.erb
cp ${extra_dir}_tmp/${tenant}_show_sidebar.html.erb app/views/shared/_show_sidebar.html.erb
cp ${extra_dir}_tmp/${tenant}_extras.scss app/assets/stylesheets/extras.scss
cp ${extra_dir}_tmp/${tenant}_variables.scss app/assets/stylesheets/_variables.scss
#
## so far, these two css files are only needed for cinefiles, for tiles on the splash page
cp ${extra_dir}_tmp/${tenant}_tiles.css app/assets/stylesheets/tiles.css
cp ${extra_dir}_tmp/${tenant}_normalize.min.css app/assets/stylesheets/normalize.min.css
#
## custom signup for cinefiles
cp ${extra_dir}_tmp/${tenant}_new.html.erb app/views/devise/registrations/new.html.erb
#
## custom cinefiles restricted PDF warning
cp ${extra_dir}_tmp/${tenant}_pdfs.html.erb app/views/shared/_pdfs.html.erb
#
## custom cinefiles rendering WARC files
cp ${extra_dir}_tmp/${tenant}_warcs.html.erb app/views/shared/_warcs.html.erb
#
# custom error pages
if [ -f "${extra_dir}_tmp/${tenant}_not_found.html.erb" ]; then
  cp ${extra_dir}_tmp/${tenant}_errors_controller.rb app/controllers/errors_controller.rb
  cp ${extra_dir}_tmp/${tenant}_errors_helper.rb app/helpers/errors_helper.rb
  cp ${extra_dir}_tmp/${tenant}_not_found.html.erb app/views/errors/not_found.html.erb
  cp ${extra_dir}_tmp/${tenant}_internal_server_error.html.erb app/views/errors/internal_server_error.html.erb
  cp ${extra_dir}_tmp/${tenant}_404.jpg public/404.jpg
  cp ${extra_dir}_tmp/${tenant}_500.jpg public/500.jpg
  # you have to remove the default error pages otherwise they supersede the custom ones
  rm public/404.html
  rm public/500.html
fi
#
## other customizations: social, tracking ids, etc.
cp ${extra_dir}_tmp/${tenant}_social.html.erb app/views/shared/_social.html.erb
cp ${extra_dir}_tmp/${tenant}_site_image.jpg public/site_image.jpg
#
# custom global alerts (via global_alerts gem)
cp ${extra_dir}_tmp/${tenant}_global_alerts.rb config/initializers/global_alerts.rb
mkdir app/views/global_alerts && cp ${extra_dir}_tmp/${tenant}_global_alerts.html.erb app/views/global_alerts/_global_alerts.html.erb
#
# get rid of the working directory, etc.
rm -f app/assets/stylesheets/normalize.min.css
rm -rf ${extra_dir}_tmp
