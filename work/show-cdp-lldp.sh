#!/usr/bin/env bash

# sniff CDP and LLDP packets for debugging purposes.
# source: https://darksideclouds.wordpress.com/2016/10/08/get-information-about-cdp-and-lldp/


if [ -n "$1" ]; then
	inter="$1"
else
	inter="eth0"
fi

sudo tcpdump -nnvi "$inter" -s 1500 -c 1 '(ether[20:2]=0x2000 or ether[12:2]=0x88cc )'
