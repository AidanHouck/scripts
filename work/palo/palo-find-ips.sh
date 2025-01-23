#!/usr/bin/env bash

# Search through a palo config export and find all rules that use hard-coded IPs instead of objects

set -euo pipefail

regex='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?$'
INPUT='data/5586.xml'

# https://stackoverflow.com/a/7052168
read_dom () {
    local IFS=\>
    read -rd \< ENTITY CONTENT
	local ret=$?
	TAG_NAME=${ENTITY%% *}
	ATTRIBUTES=${ENTITY#* }
	return $ret
}

parse_dom() {
	if [[ $TAG_NAME = "entry" ]]; then
		eval local "$ATTRIBUTES"
		# Name is gathered from the eval above
		# shellcheck disable=SC2154
		policy=$name
	fi
}

while read_dom; do
	parse_dom
	if [[ $ENTITY = "member" ]] && [[ $CONTENT =~ $regex ]]; then
		if [[ $tag_prev == "source" ]] || [[ $tag_prev == "destination" ]]; then
			echo "\"$policy\",\"$tag_prev\",\"$CONTENT\""
		fi
	fi
	tag_prev=$TAG_NAME
done < "$INPUT"

