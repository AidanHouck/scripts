#!/usr/bin/env bash

# Query Panorama for pending changes
set -eou pipefail

readonly PALO_API='.palo_api'

PANO="$(cat .palo_fqdn)"
readonly PANO

# Preview panorama config diff
preview_pan_diff() {
	config_running=$(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=op" \
		--data-urlencode "cmd=<show><config><running/></config></show>" \
		-s)

	config_candidate=$(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=op" \
		--data-urlencode "cmd=<show><config><candidate/></config></show>" \
		-s)

	diff -u -B <(echo "$config_running") <(echo "$config_candidate") | tail -n +4 | less -FXRfM
}

./palo-api-key.sh
preview_pan_diff

