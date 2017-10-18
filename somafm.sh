#!/bin/sh

if [ ! -z `readlink $0` ]
then
	dir=`dirname $(readlink -f $0)`
else
	dir=`dirname $0`
fi

function depend {
	cvlc --version &> /dev/null
	if [ $? -ne 0 ]
	then
		fatal "Vlc is not installed."
	fi
}
	
function banner {
	clear
	echo "####################################################d@h03####"
	echo " ______   ______   _________   ______     ______  _________"
	echo "/ |      / |  | \ | | | | | \ | |  | |   | |     | | | | | \ "
	echo "'------. | |  | | | | | | | | | |__| |   | |---- | | | | | |"
	echo " ____|_/ \_|__|_/ |_| |_| |_| |_|  |_|   |_|     |_| |_| |_|"
	echo "#############################################################"
	echo
	echo "[+] Channel list last modified "`stat $dir/channels.soma | grep "Modify" | awk '{print $2}'`
	echo
	echo "1) List channels"
	echo "2) Get a fresh channel list"
	echo "3) Listen to a channel"
	echo "*) Exit"
	echo 
}

function fatal {
	echo "[!!] Error: "$1" Exiting..."
	exit 1
}

function check {
	pid=`pgrep vlc`
	if [ ! -z $pid ]
	then
		echo "[!] Vlc is already running with pid "$pid
		read -p "[*] Kill? [y/n] " ans
		case $ans in
			y)
				kill -9 $pid
				;;
			n)
				echo "[!] Okay then... Bye!"
				exit 0
				;;
			*)
				fatal "Invalid answer."
				;;
		esac
	fi
				

	if [ ! -e $dir/channels.soma ]
	then
		echo "[!] Channel list is not available."
		echo "[+] Getting the channel list..."
		getChan
	fi
}

function playChan {
	cvlc http://somafm.com/$1130.pls 2 &> /dev/null & 
	echo "[+] Playing $1"
	exit 0
}

function getChan {
	echo "[+] Getting a fresh channel list.."
	curl https://somafm.com/listen/ 2> /dev/null | grep "<\!-- Channel: " | awk '{print $3}' > $dir/channels.soma 
	banner
	
}

depend
check
banner

while :
do
	read  -p "----> " ans
	case $ans in
		1)
			less $dir/channels.soma
			;;
		2)
			getChan
			;;
		3)
			read -p "[*] Eneter the channel name: " chan
			playChan $chan
			;;
		*)
			exit 0
			;;
	esac
done
