#! /bin/bash


adb logcat | grep --color -i -e $@

