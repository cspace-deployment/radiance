#!/usr/bin/env bash
#set -e
#set -x
tenant=$1
portal_config_file=$2
current_directory=`pwd`
extra_dir="../extras"

# check the command line parameters

if [ ! -f "${portal_config_file}" ]; then
  echo "Can't find portal config file '${portal_config_file}'. Please verify name and location"
  echo "$0 tenant portal_config_file"
  exit
fi

cd portal

if [ ! -d "${extra_dir}" ]; then
  echo "Can't find directory '${extra_dir}'. Please verify name and location"
  echo "$0 tenant portal_config_file"
  exit
fi

# ensure that the code is fresh
git checkout -- ${extra_dir}/*
perl -i -pe "s/#TENANT#/${tenant}/g" ${extra_dir}/*

# configure BL using existing Portal config file
python3 ${extra_dir}/ucb_bl.py ${portal_config_file} > bl_config_temp.txt
cat ${extra_dir}/catalog_controller.template bl_config_temp.txt > app/controllers/catalog_controller.rb
rm bl_config_temp.txt

# nb: the header logos for all ucb tenants are already in the public static directory
#     we just need to copy the one for this tenant to the right place.
cp public/header-logo-${tenant}.png public/header-logo.png
cp ${extra_dir}/cspace_fav.png app/assets/images/favicon.png

# use the generic header, footer, etc. partials
cp ${extra_dir}/_header_navbar.html.erb app/views/shared/
cp ${extra_dir}/_footer.html.erb app/views/shared/
cp ${extra_dir}/_splash.html.erb app/views/shared/
cp ${extra_dir}/_home_text.html.erb app/views/catalog/
cp ${extra_dir}/_search_form.html.erb app/views/catalog/

# we may someday add customized versions of these partials, but not yet
cp ${extra_dir}/etc/${tenant}_user_util_links.html.erb app/views/
cp ${extra_dir}/etc/${tenant}_catalog_controller.rb app/controllers/catalog_controller.rb
cp ${extra_dir}/etc/${tenant}_header_navbar.html.erb app/views/shared/_header_navbar.html.erb
cp ${extra_dir}/etc/${tenant}_footer.html.erb app/views/shared/_footer.html.erb
#cp ${extra_dir}/etc/${tenant}_home_text.html.erb app/views/catalog/_home_text.html.erb
#cp ${extra_dir}/etc/${tenant}_search_form.html.erb app/views/catalog/_search_form.html.erb
cp ${extra_dir}/etc/${tenant}_splash.html.erb app/views/shared/_splash.html.erb

# scss customizations
cp ${extra_dir}/etc/${tenant}_extras.scss app/assets/stylesheets/extras.scss

# generic helpers and config, but they do need to be configured per-tenant
cp ${extra_dir}/application_helper.rb app/helpers
cp ${extra_dir}/catalog_helper_behavior.rb app/helpers/blacklight
cp ${extra_dir}/blacklight.yml config
cp ${extra_dir}/blacklight.en.yml config/locales

# to make a new splash partial for a tenant.
# e.g. pick out 15 images to include in 4 x 4 splash partial
# python ${extra_dir}/etc/pick8.py 4
# python ${extra_dir}/etc/makestatic.py ${tenant}.static.csv > app/views/shared/_splash.html.erb
# but here, we will just install the existing splash partial
cp ${extra_dir}/etc/${tenant}_splash.html.erb app/views/shared/_splash.html.erb
