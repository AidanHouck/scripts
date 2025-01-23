#!/usr/bin/env bash

# Go through all *bin directories on a system and list file types

DIRS='/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
EXCLUDE_REGEX='ELF|symbolic'

while IFS= read -r dir; do
	[ -d "${dir}" ] || continue # verify dir exists
	[ "$(ls -A "${dir}")" ] || continue # verify dir is not empty

	file "${dir}"/* | grep -Ev "$EXCLUDE_REGEX"
done < <(echo "$DIRS" | tr ':' '\n')

