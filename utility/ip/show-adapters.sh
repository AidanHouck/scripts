#!/usr/bin/env bash

# Print all connected adapters

ip -4 a | grep -E '.: .*: <' | cut -d' ' -f2 | sed 's/.$//g'

