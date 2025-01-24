#!/usr/bin/env bash

# Print the current default gateway through `ip route show`

ip route show | head -n1 | cut -d' ' -f3

