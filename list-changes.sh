#!/bin/bash

export GIT_PAGER=cat

if [ $# == 1 ]; then
        git diff --quiet $1..$REPO_REMOTE/$REPO_RREV
        if [ $? == 1 ]; then
                git log --pretty="format: %h %s" --reverse $1..$REPO_REMOTE/$REPO_RREV
        fi
fi

git diff --quiet $REPO_REMOTE/$REPO_RREV..HEAD
if [ $? == 1 ]; then
        git log --pretty="format:%Cgreen %h %s" --reverse $REPO_REMOTE/$REPO_RREV..HEAD
        tput setf 7
fi

git diff --quiet --staged
if [ $? == 1 ]; then
        tput setf 6
        echo " Staged Changes"
        tput setf 7
        git diff --stat --staged
fi

git diff --quiet
if [ $? == 1 ]; then
        tput setf 5
        echo " Unstaged Changes"
        tput setf 7
        git diff --stat
fi


