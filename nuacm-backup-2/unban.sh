#!/bin/bash +x
while true;
do

#	echo Currently Banned IP Addresses:

#	iptables -L FORWARD | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | uniq

	echo Input IP Address to UNBAN
	read ipaddr
	iptables -D FORWARD -s $ipaddr -j DROP
	CTR=0
	#until [ iptables -C FORWARD -s $ipaddr -j DROP 2>&1 | grep iptables -c > /dev/null ] && [CTR >= 50]
	#do
	#	iptables -D FORWARD -s $ipaddr -j DROP
	#	CTR=CTR+1
	#done

done
