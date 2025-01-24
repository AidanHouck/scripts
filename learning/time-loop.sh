#!/usr/bin/env bash

# continuously show the time, updating every second

while true
do
	date +"It is %A, %B %d. The time is %T %p"
	sleep 1
done

