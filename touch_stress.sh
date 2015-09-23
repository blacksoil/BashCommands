#! /bin/bash

#Setup:
# 1. Reboot the device
# 2. Open settings page
# 3. Hit home button
# (Note: Make sure only Settings page appears on recent-apps pane)
# 4. Run the script


function stress() {
	# Tap Recent Button
	adb shell input tap 800 1880 && 
	# Tap the only recent app, which supposed to be Settings
	sleep 1 && 
	(adb shell input tap 750 973 && adb shell am stack list | head -2 | grep Settings &&
	# Tap home button
	sleep 1 && 
	adb shell input tap 618 1848 && sleep 1 && return 0) || return 1
}

COUNT=1;
while [ 1 ]; do
	stress
	retval=$?
	if [ $retval -ne "0" ]; then
		echo "Failed at $COUNT iteration";
      		exit 1
	fi

echo "Num of iterations=$COUNT";
((COUNT++));
done;
