# configure BL using existing Portal config file
python3 extras/ucb_bl.py $1 > bl_config_temp.txt
cat extras/catalog_controller.template bl_config_temp.txt > bampfa_catalog_controller.rb
rm bl_config_temp.txt

# to make a new splash partial for a tenant.
# e.g. pick out 15 images to include in 4 x 4 splash partial
python3 extras/etc/pick8.py 4
python3 extras/etc/makestatic.py bampfa.static.csv > bampfa_splash.html.erb
