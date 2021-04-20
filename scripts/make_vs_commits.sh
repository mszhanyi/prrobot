#!/bin/bash

set -ex

is_in_local () {
    local branch=${1}
    local existed_in_local=$(git branch --list ${branch})

    if [[ -z ${existed_in_local} ]]; then
        echo 0
    else
        echo 1
    fi
}

is_in_remote() {
    local branch=${1}
    local existed_in_remote=$(git ls-remote --heads origin ${branch})

    if [[ -z ${existed_in_remote} ]]; then
        echo 0
    else
        echo 1
    fi
}

add_vs_commit () {
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

    if [[ "$(is_in_local "zhanyi/updatevs")" == "1" ]] ; then
        git branch -d zhanyi/updatevs
    fi

    if [[ "$(is_in_remote "zhanyi/updatevs")" == "1" ]] ; then
        git push origin --delete zhanyi/updatevs
    fi

    git checkout -b zhanyi/updatevs

    python ../scripts/updatevsver.py
    
    # create pure commit
    pwd
    ls
    git add .circleci/scripts/*.ps1
    git commit -m "Update Lastest VS"
    git status
    git push --set-upstream origin zhanyi/updatevs

    #create combine pr for test.
    if [[ repo == "pytorch" ]]; then
        git checkout -d zhanyi/combpr4vs
        git add .circleci/scripts/binary_checkout.sh
        git commit -m "combine builder branch"
        git status
        git push --set-upstream origin zhanyi/combpr4vs
    fi
}

python -m pip install lxml
add_vs_commit  "builder"
add_vs_commit  "pytorch"


