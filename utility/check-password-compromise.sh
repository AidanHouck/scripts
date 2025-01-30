#!/usr/bin/env bash

# Check if a password is found at haveibeenpwned.com

if [ -z "$1" ]; then
	echo Usage:
	echo - Add password to check against HIBP
	echo - "$0 P@ssw0rd!"
	exit 1
fi

pass="$1"
pass_sha1=$(echo -n "$pass" |\
	sha1sum |\
	cut -d' ' -f1 |\
	tr '[:lower:]' '[:upper:]')

pass_sha1_prefix=$(head -c5 <<< "$pass_sha1")
pass_sha1_suffix=$(tail -c+6 <<< "$pass_sha1")

URL="https://api.pwnedpasswords.com/range/${pass_sha1_prefix}"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"

output=$(curl --user-agent "$USER_AGENT" \
	--header "Add-Padding:true" \
	--silent \
	"$URL")

if match=$(grep "$pass_sha1_suffix" <<<"$output" | tr -d '\r'); then
	echo "Warning: Password has been breached $(cut -d':' -f2 <<<"$match") times."
else
	echo "Password was not breached."
fi

