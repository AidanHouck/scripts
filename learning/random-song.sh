#!/usr/bin/env bash

# Retrieve a random song from Apple's iTunes API
# https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/

load() {
	# Echo, find key pair, strip to just value, remove leading and trailing "'s
	echo "$output" | grep -o "$1"'":"[^"]*"' | cut -d':' -f2- | sed 's/^.\|.$//g'
}

# random number
high=3
low=1
randNum=$((1 + $RANDOM % 3))

# random 2 letters
rand=$(echo "$RANDOM" | md5sum | head -c "$randNum")

output=$(curl -s 'https://itunes.apple.com/search?term='"$rand"'&media=music&entity=song&limit=1')

# this doesn't work since I can't know the range that iTunes uses
#curl -s 'https://itunes.apple.com/lookup?id='"$rand"

if [[ $(load 'artistName') == "" ]]; then
	# No response recieved from API, try again
	"$0"
	exit 1
fi

echo -n "Artist name: " && load 'artistName'
echo -n "Song name: " && load 'trackName'
echo -n "Song genre: " && load 'primaryGenreName'
echo -n "iTunes link: " && load 'trackViewUrl'

