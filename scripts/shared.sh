#!/bin/bash

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