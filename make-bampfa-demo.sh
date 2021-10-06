# these are the files that need to be copied over on top of an existing cinefiles
# rails installation to "convert" it into a bampfa demo.
# 
# instructions: 1) install the cinefiles app in the usual way. 2) run this script from within the 'radiance' repo
#
cd extras
cp etc/bampfa_splash.html.erb ../portal/app/views/shared/_splash.html.erb
cp etc/bampfa-custom/catalog_controller.rb ../portal/app/controllers/catalog_controller.rb
cp etc/bampfa-custom/_header_navbar.html.erb ../portal/app/views/shared/_header_navbar.html.erb
cp etc/bampfa-custom/_footer.html.erb ../portal/app/views/shared/_footer.html.erb
#cp etc/bampfa-custom/_splash.html.erb ../portal/~/projects/search_cinefiles/app/views/shared/_splash.html.erb
cp etc/bampfa-custom/header-logo-bampfa.png ../portal/public/header-logo-bampfa.png
cp etc/bampfa-custom/imls.png ../portal/public/imls.png
cp etc/bampfa-custom/extras.scss ../portal/app/assets/stylesheets/extras.scss
cp etc/bampfa-custom/catalog_helper_behavior.rb ../portal/app/helpers/blacklight/catalog_helper_behavior.rb
cp etc/bampfa-custom/application_helper.rb ../portal/app/helpers/application_helper.rb
cp etc/bampfa-custom/_social.html.erb ../portal/app/views/shared/_social.html.erb
cp etc/bampfa-custom/blacklight.yml ../portal/config/blacklight.yml
cp etc/bampfa-custom/global_alerts.rb ../portal/config/initializers/global_alerts.rb
cp etc/bampfa-custom/production.rb ../portal/config/environments/production.rb
cp etc/bampfa-custom/_show_sidebar.html.erb ../portal/app/views/catalog/_show_sidebar.html.erb
