#!/bin/bash

set -ex

source ./shared.sh

add_vs_commit () {
    repo=${1}
    cd ../${repo}
    git status
    git config --local user.email "mszhanyi@users.noreply.github.com"
    git config --local user.name "mszhanyi"
    git remote add upstream https://github.com/pytorch/${repo}
    git remote -v
    git fetch upstream
    if [ "${repo}" == "builder" ]; then
        git merge upstream/main
    else
        git merge upstream/master
    fi
    git status
    git remote set-url origin https://mszhanyi:${pytorch_token}@github.com/mszhanyi/${repo}.git
    git push

    remove_existing_branch zhanyi/updatevs
    git checkout -b zhanyi/updatevs

    python ../scripts/updatevsver.py
    
    # create pure commit
    git add *.ps1
    git add *.md
    git commit -m "Update Lastest VS"
    git status
    git push --set-upstream origin zhanyi/updatevs

    #create combine pr for test.
    if [[ ${repo} == "pytorch" ]]; then
        remove_existing_branch zhanyi/combpr4vs
        git checkout -b zhanyi/combpr4vs

        git add .circleci/scripts/binary_checkout.sh
        git commit -m "combine builder branch"
        git status
        git push --set-upstream origin zhanyi/combpr4vs
    fi
}

python -m pip install lxml
add_vs_commit  "builder"
add_vs_commit  "pytorch"


