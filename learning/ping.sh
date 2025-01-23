#!/usr/bin/env bash

# determine whether or not a given host is alive and responding to ICMP

ADDRESS="$1"
#ADDRESS=$HOST #localhost on non-wsl machines

count=2
timelimit=2

if [[ -z $1 ]]; then
	echo please input an address to ping
	exit 1
fi

ping -w "$timelimit" -c "$count" "$ADDRESS" 1>/dev/null 2>/dev/null

result=$?

if [[ "$result" -eq 0 ]]; then
	echo alive
else
	echo dead
fi

