#! /bin/bash

adb sync && sleep 1 && adb shell stop && sleep 1 && adb shell start
