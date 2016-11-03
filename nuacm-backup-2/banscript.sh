#!/bin/sh
tail -fn0 /var/log/messages | awk '
/IPTABLES-DROP/ {
	ip=substr($12,5,20);
	cmd="iptables -L | grep " ip
	cmd | getline output
	close(cmd)
	if(length(output) <= 0){ 
		print output; 
		system("/home/nuacm/ban.sh " ip "");
		print "Banned " ip;
	 }
	output=""
	 
}'
