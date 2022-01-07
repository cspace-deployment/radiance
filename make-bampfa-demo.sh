# these are the files that need to be copied over on top of an existing cinefiles
# rails installation to "convert" it into a bampfa demo.
#
# instructions: 1) install the cinefiles app in the usual way. 2) run this script from within the 'radiance' repo
#
cd extras
<<<<<<< HEAD

# application functionality/config
=======
cp etc/bampfa-custom/bampfa_splash.html.erb ../portal/app/views/shared/_splash.html.erb
cp etc/bampfa-custom/catalog_controller.rb ../portal/app/controllers/catalog_controller.rb
cp etc/bampfa-custom/_header_navbar.html.erb ../portal/app/views/shared/_header_navbar.html.erb
cp etc/bampfa-custom/_footer.html.erb ../portal/app/views/shared/_footer.html.erb
#cp etc/bampfa-custom/_splash.html.erb ../portal/~/projects/search_cinefiles/app/views/shared/_splash.html.erb
cp etc/bampfa-custom/header-logo-bampfa.png ../portal/public/header-logo-bampfa.png
cp etc/bampfa-custom/footer-logo-bampfa.png ../portal/public/footer-logo-bampfa.png
cp etc/bampfa-custom/imls.png ../portal/public/imls.png
cp etc/bampfa-custom/bampfa_404.jpg ../portal/public/404.jpg
cp etc/bampfa-custom/bampfa_not_found.html.erb ../portal/app/views/errors/not_found.html.erb
cp etc/bampfa-custom/bampfa_500.jpg ../portal/public/500.jpg
cp etc/bampfa-custom/bampfa_internal_server_error.html.erb ../portal/app/views/errors/internal_server_error.html.erb
cp etc/bampfa-custom/extras.scss ../portal/app/assets/stylesheets/extras.scss
cp etc/bampfa-custom/catalog_helper_behavior.rb ../portal/app/helpers/blacklight/catalog_helper_behavior.rb
>>>>>>> ccaca63... HMP 2xx: flesh out demo BAMPFA site a bit; customize splash page following cinefiles example; add 404/500 details; rearrange field order
cp etc/bampfa-custom/application_helper.rb ../portal/app/helpers/application_helper.rb
cp etc/bampfa-custom/blacklight.yml ../portal/config/blacklight.yml
cp etc/bampfa-custom/catalog_controller.rb ../portal/app/controllers/catalog_controller.rb
cp etc/bampfa-custom/catalog_helper_behavior.rb ../portal/app/helpers/blacklight/catalog_helper_behavior.rb
cp etc/bampfa-custom/bampfa_extras.scss ../portal/app/assets/stylesheets/extras.scss
cp etc/bampfa-custom/global_alerts.rb ../portal/config/initializers/global_alerts.rb
cp etc/bampfa-custom/production.rb ../portal/config/environments/production.rb

# custom views
cp etc/bampfa-custom/bampfa_splash.html.erb ../portal/app/views/shared/_splash.html.erb
cp etc/bampfa-custom/bampfa_header_navbar.html.erb ../portal/app/views/shared/_header_navbar.html.erb
cp etc/bampfa-custom/bampfa_footer.html.erb ../portal/app/views/shared/_footer.html.erb
cp etc/bampfa-custom/_social.html.erb ../portal/app/views/shared/_social.html.erb
cp etc/bampfa-custom/_show_sidebar.html.erb ../portal/app/views/catalog/_show_sidebar.html.erb
#cp etc/bampfa-custom/_splash.html.erb ../portal/~/projects/search_cinefiles/app/views/shared/_splash.html.erb

# images
cp etc/bampfa-custom/header-logo-bampfa.png ../portal/public/header-logo-bampfa.png
cp etc/bampfa-custom/footer-logo-bampfa.png ../portal/public/footer-logo-bampfa.png
cp etc/bampfa-custom/imls.png ../portal/public/imls.png
cp etc/bampfa-custom/bampfa_favicon.png ../portal/public/favicon.png

# error pages
cp etc/bampfa-custom/bampfa_404.jpg ../portal/public/404.jpg
cp etc/bampfa-custom/bampfa_not_found.html.erb ../portal/app/views/errors/not_found.html.erb
cp etc/bampfa-custom/bampfa_500.jpg ../portal/public/500.jpg
cp etc/bampfa-custom/bampfa_internal_server_error.html.erb ../portal/app/views/errors/internal_server_error.html.erb
