#!/usr/bin/env bash

# Toggle promiscuous mode on or off. Requires `check-pmode.sh` in the same directory

if [ -n "$1" ]; then
	int="$1"
else
	int=eth0
fi

if [[ "$(./check-pmode | grep "is enabled")" == "" ]]; then
	sudo ip link set eth0 promisc on
	echo Promiscuous mode has been enabled for "$int"
else
	sudo ip link set eth0 promisc off
	echo Promiscuous mode has been disabled for "$int"
fi

