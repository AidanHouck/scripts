#!/usr/bin/env bash

# show any currently assigned (non-loopback) IP addresses

ip -4 a | grep inet | cut -d' ' -f 6 | grep -v 127.0.0.1

