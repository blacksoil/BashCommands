#! /bin/bash


function stressCM() {
	echo "Stressing ConsoleMode... $COUNT"
	#adb reboot && echo "Time=$(date)"  && sleep 180 && [ `adb devices | wc -l ` -ne "2" ] && (adb logcat -d | grep fadeSplashEnd) && ((COUNT++)) && return 0
	adb reboot && echo "Device is just rebooted. Time=$(date)"
	TIME=1
	while [ $TIME -ne "180" ]; do
		[ `adb devices | wc -l ` -ne "2" ] && (adb logcat -d | grep fadeSplashEnd) && echo "Splash screen ended. Time=$(date)" && ((COUNT++)) && return 0
		sleep 1
		((TIME++))
	done
	return 1
}

COUNT=1
while true; do
	stressCM
	retval=$?
	if [ $retval -ne "0" ]; then
		echo "FAILED at count=$COUNT. $(date)"
		adb logcat -d > ~/tmp/cm_logs.txt
		exit 1
	else
		echo ""
	fi
done



