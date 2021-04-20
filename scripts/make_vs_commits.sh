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

    if [[ -z $(is_in_local "zhanyi/updatevs") ]]; then
        echo "remove local branch"
        git branch -d zhanyi/updatevs
    fi
    if [[ -z $(is_in_remote "zhanyi/updatevs") ]]; then
        echo "remove remote branch"
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

