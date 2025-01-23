#!/usr/bin/env bash

# given a phrase, convert into an acronym using awk
# Portable Network Graphics -> PNG

# this assumes only that the words are separated by spaces, case doesn't matter

if [ -z "$1" ]; then
	echo "Usage: $0 \"Portable Network Graphics\""
    exit 1
fi

acronym=$(echo "$1" | awk -F=' ' '{
	split($0, words, " ")

	for (i in words) {
		split(words[i], chars, "")
		output = output chars[1]
	}

	print toupper(output)

}')

echo "\"$1\" as an acronym is \"$acronym\""

