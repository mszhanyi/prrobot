#!/bin/bash

set -ex

source ./shared.sh

add_cuda_commit () {
    repo=${1}
    cd ../${repo}
    git status
    git config --local user.email "mszhanyi@users.noreply.github.com"
    git config --local user.name "mszhanyi"
    git remote add upstream https://github.com/pytorch/${repo}
    git remote -v
    git fetch upstream
    git merge upstream/master
    git status
    git remote set-url origin https://mszhanyi:${pytorch_token}@github.com/mszhanyi/${repo}.git
    git push

    branch=gh/updatecuda
    remove_existing_branch ${branch}
    git checkout -b ${branch}

    python ../scripts/updatecuda.py

    git commit -am "Update Cuda"
    git status
    git push --set-upstream origin ${branch}
}

python -m pip install lxml
add_cuda_commit  "pytorch"