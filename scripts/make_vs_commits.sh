#!/bin/bash

set -ex

add_vs_commit () {
    repo=$1
    cd ../$1
    git status
    git config --local user.email "mszhanyi@users.noreply.github.com"
    git config --local user.name "mszhanyi"
    git remote add upstream https://github.com/pytorch/$1
    git remote -v
    git fetch upstream
    git merge upstream/master
    git status
    git remote set-url origin https://mszhanyi:${pytorch_token}@github.com/mszhanyi/$1.git
    git push

    git branch -d zhanyi/updatevs
    git push origin --delete zhanyi/updatevs

    git checkout -b zhanyi/updatevs

    python ../scripts/updatevsver.py

    git commit -a -m "Update Lastest VS"
    git status
    git push --set-upstream origin zhanyi/updatevs
}

python -m pip install lxml
add_vs_commit  "pytorch"
add_vs_commit  "builder"

