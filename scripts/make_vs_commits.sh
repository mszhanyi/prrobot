#!/bin/bash

set -ex

# In bash 0 is True, 1 is False
is_in_local () {
    local branch=${1}
    local existed_in_local=$(git branch --list ${branch})

    if [[ -z ${existed_in_local} ]]; then
        echo 1
    else
        echo 0
    fi
}

is_in_remote() {
    local branch=${1}
    local existed_in_remote=$(git ls-remote --heads origin ${branch})

    if [[ -z ${existed_in_remote} ]]; then
        echo 1
    else
        echo 0
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

    if [[ $(is_in_local "zhanyi/updatevs") ]]; then
        git branch -d zhanyi/updatevs
    fi

    if [[ $(is_in_remote "zhanyi/updatevs") ]]; then
        git push origin --delete zhanyi/updatevs
    fi

    git checkout -b zhanyi/updatevs

    python ../scripts/updatevsver.py

    git commit -a -m "Update Lastest VS"
    git status
    git push --set-upstream origin zhanyi/updatevs
}

python -m pip install lxml
add_vs_commit  "pytorch"
add_vs_commit  "builder"

