#!/usr/bin/env bash

# Delete all .CR2 files without a corresponding .JPG in the same directory

RAW_EXT='.CR2'
PIC_EXT='.JPG'

del_list=""

for file in ./*"${RAW_EXT}"; do
	base=$(basename -- "$file")
	if ! [ -e "${base%.*}""$PIC_EXT" ]; then
		del_list="${del_list} $file"
	fi
done

echo "${del_list}"

finish="-1"
while [ "$finish" = "-1" ]; do
	read -rp "Delete files? (y/n) " choice
	case "$choice" in
	  y|Y ) rm $del_list; finish=1; exit;;
	  n|N ) finish=1; exit;;
	esac
done

