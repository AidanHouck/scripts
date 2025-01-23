#!/usr/bin/env bash

# Generate a random password from /dev/urandom

# Length of password
if [ -n "$1" ]; then
	len="$1"
else
	len=24
fi
len10=$((len * 10))

# Allowed chars
chars='a-zA-Z0-9~!@#$%^&*`_[]{}()\|;:,.<>?=+-'

#chars='a-zA-Z'
#chars='a-zA-Z0-9'
#chars='a-zA-Z0-9~!@#$%^&*_+=-'

dd if=/dev/urandom bs="$len10" count=1 2>/dev/null | tr -dc "$chars" | cut -c -"$len"

