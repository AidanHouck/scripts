#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash sshpass grepcidr
# shellcheck shell=bash

# Find an object given an IP address.
set -eou pipefail

readonly PALO_FQDN='.palo_fqdn'
readonly PALO_USER='.palo_user'
readonly PALO_PASS='.palo_pass'

ssh_output=$(sshpass -f "$PALO_PASS" \
	ssh -q -o StrictHostKeyChecking=no \
	"$(cat "$PALO_USER")@$(cat "$PALO_FQDN")" << EOF
set cli scripting-mode on
set cli config-output-format set

configure
show device-group On-Prem-DG address | match ip-netmask\|ip-range
exit
exit

EOF
)

prompt="$(cat "$PALO_USER")@Panorama# "

current_subnets=$(printf %s "$ssh_output" | \
	tr '\n' '~' | \
	sed 's/.*'"${prompt}"'\(.*\)\[edit\].*/\1/g' | \
	tr '~' '\n' |\
	sed 's/^.*\(ip-netmask\|ip-range\) \(.*\)$/\2/g')

while IFS= read -r cidr; do
	if grepcidr "$cidr" <<< "$1" 1>/dev/null; then
		echo "$cidr"
		break
	fi
done <<< "$current_subnets"

