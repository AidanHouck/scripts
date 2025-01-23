#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo Usage:
	echo - Add URL to check
	echo - "$0 https://paypal.com"
	exit 1
fi

URL="$1"
curl -skI "$URL" | grep strict-transport-security

