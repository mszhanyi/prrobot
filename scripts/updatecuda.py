#!/usr/bin/env python3

import os
import lxml.html as lh

from .utils import updatefile

def update_build_definition(major_version, minor_version, master_only=True):
    file_name = ".circleci/cimodel/data/windows_build_definitions.py"
    updates = []
    with open(file_name, "r") as f:
        lines = f.readlines()
        i = 0
        for line in lines:
            if line.find(f"# VS2019 CUDA-{major_version}"):
                indent_str = "    "
                updates.append((i, f"{indent_str}# VS2019 CUDA-{major_version}.{minor_version}"))
                updates.append((i+1, f"{indent_str}WindowsJob(None, _VC2019, CudaVersion({major_version}, {minor_version})),"))
                master_only_str = ", master_only_pred=TruePred" if master_only else ""
                updates.append((i+2, f"{indent_str}WindowsJob(1, _VC2019, CudaVersion({major_version}, {minor_version}){master_only_str}),"))
                updates.append((i+3, f"{indent_str}WindowsJob(2, _VC2019, CudaVersion({major_version}, {minor_version}){master_only_str}),"))
                break
            i += 1
    updatefile(file_name, updates)

if __name__ == "__main__":
    major_version = os.environ.get["CUDA_MAJOR_VERSION"]
    minor_version = os.environ.get["CUDA_MINOR_VERSION"]
    update_build_definition(major_version, minor_version)



