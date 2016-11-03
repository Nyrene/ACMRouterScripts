#!/bin/bash
if [ $1 == "8.8.8.8" ] || [ $1 == "8.8.4.4" ]
then
	echo Trying to ban $1
else
	if iptables -C FORWARD -s $1 -j DROP 2>&1 | grep iptables -c 
	then
		echo banning $1
		iptables -I FORWARD -s $1 -j DROP
	else
		echo already banned $1
		#for debug only
	fi
fi
