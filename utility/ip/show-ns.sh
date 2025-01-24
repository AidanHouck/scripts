#!/usr/bin/env bash

# Print the currently active nameserver in `/etc/resolv.conf`

grep nameserver /etc/resolv.conf | cut -d' ' -f2-

