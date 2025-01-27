#!/usr/bin/env bash

# Query Panorama for pending changes via SSH
set -eou pipefail

readonly PALO_FQDN='.palo_fqdn'
readonly PALO_USER='.palo_user'

ssh_output=$(ssh -q -o StrictHostKeyChecking=no \
	"$(cat "$PALO_USER")@$(cat "$PALO_FQDN")" << EOF
set cli scripting-mode on
set cli config-output-format set

show config diff
exit

EOF
)

prompt="$(cat "$PALO_USER")@Panorama> "
prompt_3x="${prompt}${prompt}${prompt}"

printf %s "$ssh_output" | \
	tr '\n' '~' | \
	sed 's/.*'"${prompt_3x}"'\(.*\)'"${prompt}"'/\1/g' | \
	tr '~' '\n'

