#!/usr/bin/env bash

# list all public github repos for a given username

if [[ -z $1 ]]; then
	echo Error: Please specify a GitHub username
	exit 1
fi

input="$1"
#input="octocat"

URL="https://api.github.com"

call () {
	# call "users" or call "orgs"
	full_URL=$URL'/'$1'/'$input'/repos'
	output=$(curl -s "$full_URL")
}

check () {
	if ! grep -q "Not Found" <<< "$output"; then
		return 1
	else
		return 0
	fi
}

# Was the input a user?
call "users"
if check; then
	# Didn't work, try orgs
	call "orgs"
	if check; then
		# Still didn't work
		echo Error: User / Org not found
		exit 1
	fi
fi

echo "$1's repos are:"
grep "full_name" <<< "$output" | tr -s ' ' | cut -d' ' -f 3 | sed 's/",$//' | sed 's/^"//'

