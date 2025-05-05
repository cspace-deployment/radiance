#!/usr/bin/env bash
#set -e
#set -x
tenant=$1
current_directory=`pwd`
extra_dir="${current_directory}/extras"

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
# perl -i -pe "s/#TENANT#/${tenant}/g" ${extra_dir}_tmp/* 2>&1
for f in $(find ${extra_dir}_tmp); do [[ -f $f ]] && perl -i -pe "s/#TENANT#/${tenant}/g" $f 2>&1; done

# now apply customizations, if any

# nb: the header logos for all ucb tenants are already in the public static directory
mkdir app/views/shared

# copy a favicon
# right now we only have PNG favicons...
#cp ${extra_dir}_tmp/${tenant}_favicon.ico app/assets/images/favicon.ico
# cp ${extra_dir}_tmp/cspace_fav.png app/assets/images/favicon.png
cp ${extra_dir}_tmp/${tenant}/app/assets/images/favicon.png app/assets/images/favicon.png

# generic helpers and config, but some do need to be configured per-tenant
cp ${extra_dir}_tmp/${tenant}/app/helpers/application_helper.rb app/helpers
cp ${extra_dir}_tmp/${tenant}/app/presenters/thumbnail_presenter.rb app/presenters/thumbnail_presenter.rb
cp ${extra_dir}_tmp/${tenant}/config/routes.rb config/routes.rb
cp ${extra_dir}_tmp/common/config/blacklight.yml config
cp ${extra_dir}_tmp/${tenant}/config/locales/blacklight.en.yml config/locales
mkdir app/helpers/blacklight_advanced_search
cp ${extra_dir}_tmp/common/app/helpers/blacklight_advanced_search/advanced_helper_behavior.rb app/helpers/blacklight_advanced_search
#
cp ${extra_dir}_tmp/${tenant}/config/environments/production.rb config/environments/production.rb
# cp ${extra_dir}_tmp/${tenant}_blacklight.en.yml config/locales/blacklight.en.yml
#
## use our generic header, footer, etc. partials
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_header_navbar.html.erb app/views/shared/
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_footer.html.erb app/views/shared/
#
## possible customized partials
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_user_util_links.html.erb app/views/shared/_user_util_links.html.erb
rm -f app/views/shared/_show_sidebar.html.erb
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_show_sidebar.html.erb app/views/shared/

cp ${extra_dir}_tmp/${tenant}/app/controllers/catalog_controller.rb app/controllers/catalog_controller.rb

if [ -d "${extra_dir}_tmp/${tenant}/app/models/search_builder.rb" ]; then
  cp ${extra_dir}_tmp/${tenant}/app/models/search_builder.rb app/models/
else
  cp ${extra_dir}_tmp/common/app/models/search_builder.rb app/models/
fi

rm -rf lib/solr
if [ -d "${extra_dir}_tmp/${tenant}/lib/solr" ]; then
  cp -a ${extra_dir}_tmp/${tenant}/lib/solr/. lib/solr/
fi

# splash page goes into _home_text_html.erb for now
# mkdir app/views/catalog
rm -f app/views/catalog/_document_gallery.html.erb
rm -f app/views/catalog/_document_slideshow.html.erb
rm -f app/views/catalog/_show_sidebar.html.erb
rm -f app/views/catalog/_index_default.html.erb
rm -f app/views/catalog/_show_default.html.erb
rm -f app/views/catalog/_show_preview.html.erb
rm -f app/views/catalog/_slideshow_modal.html.erb
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_document_gallery.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_document_slideshow.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_home_text.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_show_sidebar.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_index_default.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_show_default.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_show_preview.html.erb app/views/catalog/
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_slideshow_modal.html.erb app/views/catalog/

cp ${extra_dir}_tmp/${tenant}/app/assets/stylesheets/extras.scss app/assets/stylesheets/extras.scss
cp ${extra_dir}_tmp/${tenant}/app/assets/stylesheets/_variables.scss app/assets/stylesheets/_variables.scss
#
## so far, these two css files are only needed for cinefiles, for tiles on the splash page
rm -f app/assets/stylesheets/tiles.css
cp ${extra_dir}_tmp/${tenant}/app/assets/stylesheets/tiles.css app/assets/stylesheets/tiles.css
# cp ${extra_dir}_tmp/${tenant}_normalize.min.css app/assets/stylesheets/normalize.min.css
#
## custom signup for cinefiles and pahma
rm -rf app/views/devise
if [ -f "${extra_dir}_tmp/${tenant}/app/views/devise/registrations/new.html.erb" ]; then
  mkdir app/views/devise
  mkdir app/views/devise/passwords
  mkdir app/views/devise/registrations
  mkdir app/views/devise/sessions
  cp ${extra_dir}_tmp/${tenant}/app/views/devise/passwords/new.html.erb app/views/devise/passwords/new.html.erb
  cp ${extra_dir}_tmp/${tenant}/app/views/devise/registrations/new.html.erb app/views/devise/registrations/new.html.erb
  cp ${extra_dir}_tmp/${tenant}/app/views/devise/sessions/new.html.erb app/views/devise/sessions/new.html.erb
fi
#
## custom cinefiles restricted PDF warning
rm -f app/views/shared/_pdfs.html.erb
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_pdfs.html.erb app/views/shared/_pdfs.html.erb
#
## custom cinefiles rendering WARC files
rm -f app/views/shared/_warcs.html.erb
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_warcs.html.erb app/views/shared/_warcs.html.erb
#
# custom error pages
rm -rf app/views/errors
if [ -f "${extra_dir}_tmp/${tenant}/app/views/errors/not_found.html.erb" ]; then
  # cp ${extra_dir}_tmp/${tenant}_errors_controller.rb app/controllers/errors_controller.rb
  # cp ${extra_dir}_tmp/${tenant}_errors_helper.rb app/helpers/errors_helper.rb
  cp ${extra_dir}_tmp/${tenant}/app/views/errors/not_found.html.erb app/views/errors/not_found.html.erb
  cp ${extra_dir}_tmp/${tenant}/app/views/errors/internal_server_error.html.erb app/views/errors/internal_server_error.html.erb
  cp ${extra_dir}_tmp/${tenant}/public/404.jpg public/404.jpg
  cp ${extra_dir}_tmp/${tenant}/public/500.jpg public/500.jpg
  # you have to remove the default error pages otherwise they supersede the custom ones
  rm public/404.html
  rm public/500.html
fi
#
## other customizations: social, tracking ids, etc.
cp ${extra_dir}_tmp/${tenant}/app/views/shared/_social.html.erb app/views/shared/_social.html.erb
cp ${extra_dir}_tmp/${tenant}/public/site_image.jpg public/site_image.jpg
#
# custom global alerts (via global_alerts gem)
cp ${extra_dir}_tmp/${tenant}/config/initializers/global_alerts.rb config/initializers/global_alerts.rb
rm -rf app/views/global_alerts
if [ -f "${extra_dir}_tmp/${tenant}/app/views/global_alerts/_global_alerts.html.erb" ]; then
  mkdir app/views/global_alerts
  cp ${extra_dir}_tmp/${tenant}/app/views/global_alerts/_global_alerts.html.erb app/views/global_alerts/_global_alerts.html.erb
fi

# custom gallery
rm -f app/controllers/gallery_controller.rb
cp ${extra_dir}_tmp/${tenant}/app/controllers/gallery_controller.rb app/controllers/gallery_controller.rb
rm -rf app/components/blacklight/gallery
if [ -f "${extra_dir}_tmp/${tenant}/app/components/blacklight/gallery/slideshow_component.html.erb" ]; then
  mkdir app/components/blacklight/gallery
  cp ${extra_dir}_tmp/${tenant}/app/components/blacklight/gallery/slideshow_component.html.erb app/components/blacklight/gallery
fi
cp ${extra_dir}_tmp/${tenant}/app/components/gallery/slideshow_preview_component.rb app/components/blacklight/gallery
rm -f extras/pahma/app/views/catalog/_document_gallery.html.erb
rm -f extras/pahma/app/views/catalog/_document_slideshow.html.erb
rm -f extras/pahma/app/views/catalog/_slideshow_modal.html.erb
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_document_gallery.html.erb app/views/catalog
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_document_slideshow.js.erb app/views/catalog
cp ${extra_dir}_tmp/${tenant}/app/views/catalog/_slideshow_modal.js.erb app/views/catalog
if [ -f "${extra_dir}_tmp/${tenant}/app/views/gallery/_gallery.html.erb" ]; then
  mkdir app/views/gallery
  cp ${extra_dir}_tmp/${tenant}/app/views/gallery/_gallery.html.erb app/views/gallery/_gallery.html.erb
  cp ${extra_dir}_tmp/${tenant}/app/views/gallery/add_gallery_items.js.erb app/views/gallery/add_gallery_items.js.erb
fi

# get rid of the working directory, etc.
rm -f app/assets/stylesheets/normalize.min.css
rm -rf ${extra_dir}_tmp
