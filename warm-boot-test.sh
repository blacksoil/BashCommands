#! /bin/bash

# ADB binary
ADB=/home/aharijanto/droid/rel-roth/out/host/linux-x86/bin/adb

# How many times the device is tried to be rebooted
COUNT=0

# Global Var to hold return value of reboot_android
REBOOT_RET="1"


function reboot_android()
{
    `$ADB reboot`
    REBOOT_RET=$?
    COUNT=`expr $COUNT + 1`
}

function print_reboot_count()
{
    echo "Num reboots: $COUNT"
}

reboot_android

# If it reboots fine
while [ "$REBOOT_RET" -eq "0" ]
do
    echo "Reboot succeeded: $COUNT times"
    echo " Sleeping for 15 secs to wait until adb is ready"
    sleep 15
    `$ADB wait-for-device`
    echo "Device is ready, waiting for 30 secs to ensure system is ready"
    sleep 30
    echo "Rebooting device..."
    reboot_android
done

echo "Reboot test stopped..."
