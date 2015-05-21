#! /bin/bash

rsync -v -e $1 ssh aharijanto@apt-sc01:~/$2
