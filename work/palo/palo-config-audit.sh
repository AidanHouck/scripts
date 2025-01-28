#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash sshpass
# shellcheck shell=bash

# Query Panorama for pending changes via SSH
set -eou pipefail

readonly PALO_FQDN='.palo_fqdn'
readonly PALO_USER='.palo_user'
readonly PALO_PASS='.palo_pass'

ssh_output=$(sshpass -f "$PALO_PASS" \
	ssh -q -o StrictHostKeyChecking=no \
	"$(cat "$PALO_USER")@$(cat "$PALO_FQDN")" << EOF
set cli scripting-mode on
set cli config-output-format set

show config diff
exit

EOF
)

prompt="$(cat "$PALO_USER")@Panorama> "
prompt_3x="${prompt}${prompt}${prompt}"

red=$'\e[31m'
green=$'\e[32m'
reset=$'\e[0m'

# Check if we have bat, fallback to $PAGER then less
if type bat >/dev/null 2>&1; then
	pager="bat -p"
else
	if [ -n "$PAGER" ]; then
		pager="$PAGER"
	else
		pager="less"
	fi
fi

printf %s "$ssh_output" | \
	tr '\n' '~' | \
	sed 's/.*'"${prompt_3x}"'\(.*\)'"${prompt}"'/\1/g' | \
	tr '~' '\n' |\
	sed 's/^+.*$/'"${green}"'&'"${reset}"'/' |\
	sed 's/^-.*$/'"${red}"'&'"${reset}"'/' |\
	$pager

