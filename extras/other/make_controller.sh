extra_dir=.
portal_config_file=$1

# configure BL using existing Portal config file
python3 ${extra_dir}/ucb_bl.py ${portal_config_file} > bl_config_temp.txt
cat ${extra_dir}/catalog_controller.template bl_config_temp.txt > catalog_controller.tmp
rm bl_config_temp.txt
