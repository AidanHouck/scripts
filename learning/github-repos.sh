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
	output=$(echo $output | sed 's/, /\\n/g')
}

display () {
	# User/Repo
	echo -e $output | grep $1 | cut -d' ' -f 2 | sed 's/.$//' | sed 's/^.//'

	# Repo
	#echo -e $output | grep $1 | cut -d' ' -f 2 | sed 's/.$//' | sed 's/^.//' | sed -n 's/[^\/]*\///p'
}

check () {
	if [[ $(echo -e $output | head -n1) == "[ ]" || $(echo -e $output | head -n1 | grep "Not Found") ]]; then
		FOUND=0
	else
		FOUND=1
	fi
}

# Was the input a user?
call "users"
check
if [[ $FOUND == 0 ]]; then
	# Didn't work, try orgs
	echo Error: User not found
	call "orgs"
	if [[ $FOUND == 0 ]]; then
		echo Error: User / Org not found
	fi
	exit 1
fi

echo "$1's repos are:"
display "full_name"

