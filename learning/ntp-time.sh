#!/usr/bin/env bash

# query an NTP server for the current time

server="time.nist.gov/13"

time=$(cat </dev/tcp/"$server")
UTC=$(echo "$time" | cut -d' ' -f 3 | tr -d '\n')
EST=$(date --date="$UTC UTC" | cut -d' ' -f 4)

echo "It is $UTC UTC"
echo "That is $EST EST"

