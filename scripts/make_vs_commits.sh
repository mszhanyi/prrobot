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

is_in_remote () {
    local branch=${1}
    local existed_in_remote=$(git ls-remote --heads origin ${branch})

    if [[ -z ${existed_in_remote} ]]; then
        echo 0
    else
        echo 1
    fi
}

remove_existing_branch () {
    local branch=${1}
    if [[ "$(is_in_local ${branch})" == "1" ]] ; then
        git branch -d ${branch}
    fi

    if [[ "$(is_in_remote ${branch})" == "1" ]] ; then
        git push origin --delete ${branch}
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

    remove_existing_branch zhanyi/updatevs
    git checkout -b zhanyi/updatevs

    python ../scripts/updatevsver.py
    
    # create pure commit
    git add *.ps1
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


