#!/bin/bash

# ---- global variable ----

declare ARG_COUNT=$#
declare IP=$1

declare TAR_FILE="linux.tar.gz"
declare UNINSTALL_APK="com.example.option"
declare APK="*.apk"
declare AAKASH="aakash.sh"

declare DEV_PATH="/data/local/"

# -------------------------


function sanity_check()
{
    echo "checking whether all files are in place..."
    
    # check for $TAR_FILE
    if [ ! -f $AAKASH ];
	then
	echo "$AAKASH: not found"
	exit 0
    elif [ ! -f $TAR_FILE ];
    then
	echo "$TAR_FILE: not found"
	exit 0
    elif [ ! -f default.prop ];
    then
	echo "default.prop: not found"
	exit 0
    elif [ ! -f init.rc ];
    then
	echo "init.rc: not found"
	exit 0
    elif [ ! -f tar ];
    then
	echo "binary 'tar': not found"
	exit 0
    fi
}

function rooting()
{
    #pushing new default.prop for rooting purpose
    echo "pushing default.prop"
    adb push default.prop /
    # 
    echo "pushing flag to /"
    echo "1" > flag
    adb push flag /
    echo "STEP 1/7 : pushed default.prop and  flag to / for rooting"
    echo " "
    echo "rebooting...you need to manually power the device and run this script again"
    echo "Press ctrl+c now"
    adb reboot
}

function installing()
{
	    
    #pushing aakash.sh for chroot, mounting, and apache2
    adb push $AAKASH $DEV_PATH
    adb shell chmod 777 ${DEV_PATH}${AAKASH}
    echo "STEP 2/7 : pushed $AAKASH to $DEV_PATH"
    sleep 0.2

    #hoping that device is rooted by default.prop, this modified init.rc has an
    #entry to enable aakash.sh at boot time
    adb push init.rc /
    echo "STEP 3/7 : pushed init.rc for automatic affect of aakash.sh in future {Success}"
    sleep 0.2

    echo -e "pushing linux.tar.gz to $DEV_PATH. This might take more than 15 minutes,\n
      keep your tablet alive and wifi active"
    adb push $TAR_FILE $DEV_PATH
    echo "STEP 4/7 : finally successfully pushed the giant, now even more painful step,"
    echo "untaring it.. keep your nerves down, this will again take more than 15 minutes"
    
    adb push tar $DEV_PATH
    echo "STEP 5/7 : sent tar static binary"
    adb shell chmod 777 ${DEV_PATH}tar
    echo "changed permissions of tar binary to execute"
    
    echo "now untar the $TAR_FILE to $DEV_PATH, again this will take some time (15minutes)"
    adb shell ${DEV_PATH}tar -xvpzf ${DEV_PATH}${TAR_FILE} -C $DEV_PATH

    # remove previous installed apk if any
    adb uninstall $UNINSTALL_APK
    
    # install all apks available in current working directory
    adb install -r $APK
    echo "STEP 7/7 : all done "

    echo "Removing flag"
    adb shell rm /flag
    
    sleep 1
    echo "if you are here, that means everything went well."
    echo "THE SYSTEM WILL REBOOT IN 5 SECONDS, HIT CTRL+c to cancel"
    sleep 5
    adb reboot
    echo "It will not reboot automatically, so turn it on NOW, YES NOW"
}

function connect_device()
{
    local ADB_DEVICES=0
    sanity_check    
    # try to connect to device, loop till the device gets connected
    while [ $ADB_DEVICES -le 2 ]
    do
	adb kill-server
	adb start-server
	echo "connecting to device at IP: $IP"
	adb connect $IP
	ADB_DEVICES=$(adb devices | wc -l)
    done

    FLAG=$(adb shell cat /flag | tr -d '\r')
    # echo $FLAG
    ANS=1
    
    if [ "$FLAG" == "$ANS" ];
    then
        # echo $FLAG
	echo "installing"
    	installing	
    else
    	echo "rooting"
	rooting
    fi
}

# __init__
if [ "$ARG_COUNT" -ne 1 ];
then
    echo "Usage: $0 <IP-address>"
    exit 0
else
    connect_device
fi