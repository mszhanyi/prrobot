#!/usr/bin/env python3

import os
import re
import lxml.html as lh

import utils

def update_build_definition(major_version, minor_version, master_only=True):
    file_name = ".circleci/cimodel/data/windows_build_definitions.py"
    updates = []
    with open(file_name, "r") as f:
        lines = f.readlines()
        i = 0
        for line in lines:
            if line.find(f"# VS2019 CUDA-{major_version}") != -1:
                indent_str = "    "
                updates.append((i, f"{indent_str}# VS2019 CUDA-{major_version}.{minor_version}"))
                updates.append((i+1, f"{indent_str}WindowsJob(None, _VC2019, CudaVersion({major_version}, {minor_version})),"))
                master_only_str = ", master_only=True" if master_only else ""
                updates.append((i+2, f"{indent_str}WindowsJob(1, _VC2019, CudaVersion({major_version}, {minor_version}){master_only_str}),"))
                updates.append((i+3, f"{indent_str}WindowsJob(2, _VC2019, CudaVersion({major_version}, {minor_version}){master_only_str}),"))
                break
            i += 1
    utils.updatefile(file_name, updates)

def update_cuda_install(major_version, minor_version, installer_name):
    file_name = ".circleci/scripts/windows_cuda_install.sh"
    updates = []
    with open(file_name, "r") as f:
        lines = f.readlines()
        i = 0
        for line in lines:
            #So far, for cuda 11
            if line.find(f'"${{CUDA_VERSION}}" == "{major_version}') != -1:
                indent_str = "    "
                updates.append((i, f'{indent_str}if [[ "${{CUDA_VERSION}}" == "{major_version}.{minor_version}" ]]; then'))
                updates.append((i+1, f'{indent_str}{indent_str}cuda_installer_name="{installer_name}"'))
                packages_line = lines[i+3]
                pattern_str = r'([1-9]\d*\.?\d*)'
                new_packages = re.sub(pattern_str, f"{major_version}.{minor_version}", packages_line)
                # for cconveniency, other updated line has no \n, so we remove last char for re.sub result
                new_packages = new_packages.rstrip(new_packages[-1])
                updates.append((i+3, new_packages))
                break
            i += 1
    utils.updatefile(file_name, updates)

if __name__ == "__main__":
    major_version = os.environ.get("CUDA_MAJOR_VERSION")
    minor_version = os.environ.get("CUDA_MINOR_VERSION")
    installer_name = os.environ.get("CUDA_INSTALLER_NAME")
    master_only = os.environ.get("MASTER_ONLY") == "1"
    
    update_build_definition(major_version, minor_version, master_only=master_only)
    update_cuda_install(major_version, minor_version, installer_name)



