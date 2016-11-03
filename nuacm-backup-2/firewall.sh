#!/bin/bash

trap "kill 0" SIGINT SIGTERM EXIT

IPTABLES=/sbin/iptables
EXTIF='eth2'
INTIF='eth1'

EXTNET=''
INTNET='10.0.0.0/24'

#Flush
$IPTABLES -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F

#Enable Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

#Default Policy
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT

$IPTABLES -N LOGDROP 
$IPTABLES -A LOGDROP -m limit --limit 1000/min -j LOG --log-prefix "IPTABLES-DROP: " --log-level 4
$IPTABLES -A LOGDROP -j DROP

$IPTABLES -A INPUT -i $INTIF -j ACCEPT

#Allow connection out for server
$IPTABLES -A INPUT -i $EXTIF -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o $EXTIF -m state --state NEW,ESTABLISHED -j ACCEPT

#NAT
$IPTABLES -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
$IPTABLES -A FORWARD -i $EXTIF -o $INTIF -m state --state RELATED,ESTABLISHED -j ACCEPT

$IPTABLES -A FORWARD -m string --string "BitTorrent" --algo bm -j LOGDROP
$IPTABLES -A FORWARD -m string --string "BitTorrent protocol" --algo bm -j LOGDROP
$IPTABLES -A FORWARD -m string --string ".torrent" --algo bm -j LOGDROP
$IPTABLES -A FORWARD -m string --string "torrent" --algo bm -j LOGDROP

$IPTABLES -t mangle -A FORWARD -i $INTIF -o $EXTIF -j NFQUEUE --queue-num 0 
$IPTABLES -t filter -A FORWARD -m mark --mark 5 -j LOGDROP

#Allow all internal out
$IPTABLES -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT


l7-filter -f l7_filter.conf -q 0 &
sleep 1
./banscript.sh &
./unban.sh
