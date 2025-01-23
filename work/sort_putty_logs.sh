#!/usr/bin/env bash

# script to move puttylogs into folders based on the connected device's IP address

# read all files in current directory with `.log` extension
while IFS= read -r -d '' file; do
	directory=$(echo "$file" | grep -Eo '^\./[0-9 \.]*-')

	# file format matched
	[ -z "$directory" ] && continue

	# Dir doesn't exist yet	
	[ ! -d "$directory" ] && mkdir "$directory"

	# move file
	mv "$file" "$directory"
	echo "moved $file"

done < <(find . -maxdepth 1 -type f -print0 -name "*.log")

