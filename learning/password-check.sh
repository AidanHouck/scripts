#!/usr/bin/env bash

# check if a given string was found in the haveibeenpwned breach database

prefix=$(echo -n "$1" | sha1sum | head -c 5)
suffix=$(echo -n "$1" | sha1sum | cut -c 6- | tr -d ' '-)

output=$(curl -s "https://api.pwnedpasswords.com/range/$prefix" \
	-H 'user-agent: asdf' |\
	grep -i "$suffix" )

if [ "$output" == "" ]; then
	echo "Password not found in any breach!"
	exit 0
else
	echo -n "Password find count: "
	echo -n "$output" | cut -d':' -f2 | sed 's/ //'
	# Why does this newline with -n?
	exit 0
fi

