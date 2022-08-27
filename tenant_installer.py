#!/usr/bin/env python3
import os
import pathlib
import shutil
import sys

tenant_list = ['bampfa','cinefiles','pahma']
if len(sys.argv) <=1 or sys.argv[1] not in tenant_list:
    print("Please specify a valid tenant from this list: "+', '.join(tenant_list))
    print("Like so: `python3 tenant_installer.py TENANT`")
    sys.exit(1)
else:
    tenant = sys.argv[1]
os.chdir('extras/'+tenant)

# copy over tenant files
tenant_path = pathlib.Path('.').resolve()
app_path = pathlib.Path('../../portal').resolve()

shutil.copytree(tenant_path,app_path,dirs_exist_ok=True)

# copy over common files
common_files = [
    "app/helpers/application_helper.rb",
    "app/presenters/blacklight/thumbnail_presenter.rb"
    ]
common_dir = pathlib.Path('../common')
for file_path in common_files:
    test = app_path.joinpath(file_path).resolve()
    print(common_dir.joinpath(file_path))
    if not test.exists():
        shutil.copytree(common_dir.joinpath(file_path).parent.resolve(),test.parent.resolve(), dirs_exist_ok=True)
        tmp = str(test)+".tmp"
        tmp_lines = []
        placeholder = "#TENANT#"
        with open(test,'r') as f:
            lines = f.readlines()
            for line in lines:
                if placeholder in line:
                    line = line.replace(placeholder,tenant)
                tmp_lines.append(line)
        with open(tmp,'w') as f:
            for line in tmp_lines:
                f.write(line)
        tmp = pathlib.Path(tmp).resolve()
        test = pathlib.Path(test).resolve()
        shutil.copy(tmp,file_path)
        tmp.unlink()
