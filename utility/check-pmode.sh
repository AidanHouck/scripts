#!/usr/bin/env bash

# Check if promiscuous mode is enabled on $1/eth0

if [ -n "$1" ]; then
	int="$1"
else
	int=eth0
fi


result=$(netstat -i | grep "$int" | awk '{ print $11 }' | grep P)

if [[ "$result" == "" ]]; then
	echo Promiscuous mode is not enabled on "$int"
else
	echo Promiscuous mode is enabled on "$int"
fi

