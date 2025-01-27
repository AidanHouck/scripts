#!/usr/bin/env bash

# Interact with Palo Alto API for SOC alerts
set -eou pipefail

readonly PALO_FQDN='.palo_fqdn'
readonly PALO_USER='.palo_user'
readonly PALO_PASS='.palo_pass'
readonly PALO_API='.palo_api'

readonly PANO="$(cat .palo_fqdn)"

# Write new API key to file
write_api_key() {
	echo "Generating new API key..."
	touch "$PALO_API"
	chown houck:users "$PALO_API"
	chmod 600 "$PALO_API"
	parse_api_key get_api_key > "$PALO_API"
	echo "New API key written to \"${PALO_API}\""
}

# Fetch new API key
get_api_key() {
	echo "Requesting new API key..."
	curl -H "Content-Type: application/x-www-form-urlencoded" \
		-X POST https://"${PANO}"/api/?type=keygen \
		-d 'user='"$(cat $PALO_USER)"'&password='"$(cat $PALO_PASS)" \
		-s
}

# Parse API key from XML response
parse_api_key() {
	while read_xml; do
		if [[ $ENTITY = "key" ]]; then
			echo "$CONTENT"
		fi
	done < <("$1")
}

# Test API key is valid
test_api_key() {
	while read_xml; do
		if [[ $ENTITY = "msg" ]]; then
			echo "$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST 'https://'"${PANO}"'/api?type=op&cmd=<show><system><info></info></system></show>' \
		-s)
}

# Helper function for parsing XML
read_xml () {
	local IFS=\>
	read -rd \< ENTITY CONTENT
}

main () {
	# If PALO_API file does not exist
	if ! [ -s "$PALO_API" ]; then
		# Then get a new key and save to disk
		write_api_key
	else
		echo "Using existing \"${PALO_API}\" file"
	fi

	# It does exist, test the key is valid
	echo "Testing API key..."
	result="$(test_api_key)"
	if [ -n "${result}" ]; then
		echo "API key is no longer valid. Removing \"$PALO_API\" and re-requesting..."
		rm -f "$PALO_API"

		# Generate new key
		write_api_key

		# Re-test key
		echo "Testing API key..."
		result="$(test_api_key)"
		if [ -n "${result}" ]; then
			# If new key still doesn't work then die
			echo "ERROR: Invalid API key. Response: ${result}"
			exit 1
		fi
	fi

	echo "API key is valid."
}

# Enter program
main

