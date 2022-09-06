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
app_path = pathlib.Path('portal/').resolve()

# first copy over common files
os.chdir('extras/common')
common_dir = pathlib.Path('.')
common_files = sorted(common_dir.glob('**/*.*'))
# print(common_files)
for file_path in common_files:
    # print(file_path)
    common_file_resolved = file_path.resolve()
    print(common_file_resolved)
    dest_file = app_path.joinpath(file_path).resolve()
    print(dest_file)
    shutil.copyfile(common_file_resolved,dest_file)

    tmp = str(dest_file)+".tmp"
    tmp_lines = []
    placeholder = "#TENANT#"
    with open(dest_file,'r') as f:
        lines = f.readlines()
        for line in lines:
            if placeholder in line:
                line = line.replace(placeholder,tenant)
            tmp_lines.append(line)
    with open(tmp,'w') as f:
        for line in tmp_lines:
            f.write(line)

    tmp = pathlib.Path(tmp).resolve()
    shutil.copyfile(tmp,dest_file)
    tmp.unlink()

# copy over tenant files
tenant_path = pathlib.Path('../'+tenant)
os.chdir(tenant_path)
shutil.copytree(tenant_path,app_path,dirs_exist_ok=True)
