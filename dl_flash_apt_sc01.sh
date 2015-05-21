#! /bin/bash


dl_succeed="0"
function dl () {
    rsync -v -e ssh aharijanto@apt-sc01:~/$1 .
    dl_succeed=$?
}


dl $1
if [ $dl_succeed -eq "0" ]
then
    tar xvf $1
    folder_name=`echo $1 | cut -d "." -f 1`
    `sudo pm342 reset_recovery && sleep 1 &&cd $(pwd)/home/aharijanto/$folder_name && ./FlashFFD`

fi