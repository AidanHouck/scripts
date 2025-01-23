#!/usr/bin/env bash

# Parse a SuperPUTTY sessions.xml file, printing SessionName and Host for each match

XML_FILE='/mnt/c/Users/houck/Documents/SuperPuTTY/Sessions.XML'

if [ -z "$1" ]; then
        echo Usage:
        echo - Search by keyword: "$0" \"Office\"
        echo - List all in folder: "$0" \"Building/IDF1/\"
        echo - Search by IP: "$0" \"10.100.20.200\"
        exit 1
fi

# Read each line of the file
while IFS= read -r line
do
        # grep for match, echo raw result in a nice format
        sessionName=$(echo "$line" | grep -i "$1" | grep -o 'SessionName="[^\"]*"' | cut -d '"' -f2 )
        host=$(echo "$line" | grep -i "$1" | grep -o 'Host="[0-9\.]*"' | cut -d '"' -f2 )
        protocol=$(echo "$line" | grep -i "$1" | grep -o 'Proto="[a-zA-Z]*"' | cut -d '"' -f2 )

        # print only if we found something
        if [ -n "$sessionName" ] && [ -n "$host" ]; then
                echo "${sessionName}": "$protocol" @ "$host"
        fi

done < "$XML_FILE"
