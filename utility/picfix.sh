#!/usr/bin/env bash

# Delete all .CR2 files without a corresponding .JPG in the same directory

RAW_EXT='.CR2'
PIC_EXT='.JPG'

for file in ./*"${RAW_EXT}"; do
	base=$(basename -- "$file")
	if ! [ -e "${base%.*}""$PIC_EXT" ]; then
		rm -i "$file"
	fi
done
