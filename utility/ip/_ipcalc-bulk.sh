#!/usr/bin/env bash

# Bulk calc ip info. Requires `./ipcalc.sh`

input='_ipcalc-bulk.sh.input'
while read -r line; do
	./ipcalc.sh -a "$line" | grep 'network address' | cut -d' ' -f5
done < $input

