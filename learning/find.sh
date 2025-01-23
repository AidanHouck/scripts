#!/usr/bin/env bash

# Find a uniquely named file, starting from the given directory and working recursively.

# If anything was passed into the script on $1 use it as a starting directory,
# else default to /tmp
if [ -n "$1" ]; then
	finddir="$1"
else
	finddir="/tmp"
fi

# Same as above but with the name of the file to look for
if [ -n "$2" ]; then
	findname="$2"
else
	findname="myuniquefilename.txt"
fi

# Starting from $finddir, look recursively for any file with a specific name and print the first one.
# Also, discard error output. (if you start from `/` then you'll get lots of useless "permission denied" errors)
file=$(find "$finddir" -type f -name "$findname" -print -quit 2>/dev/null)
	# $file will look something like: /tmp/subdirectory/subsubdirectory/myuniquefilename.txt

# State whether or not the file was found. Exit if not.
if [ -n "$file" ]; then
	echo File was found
else
	echo File not found
	exit 1
fi

# Count the number of `/` chars in the result. sed is used to add newlines after each `/` character
# so that grep can easily just count the matching lines
slashcount=$(echo "$file" | sed 's/\//\/\n/g' | grep -c '/')
nameindex=$((slashcount + 1))

# Cut the output into 2 variables for the path section and name section
path=$(echo "$file" | cut -d '/' -f -"$slashcount")
name=$(echo "$file" | cut -d '/' -f $nameindex)

echo The path is "$path" and the name is "$name"

