#!/usr/bin/env bash

# (attempt to) generate an ascii table
# ref: https://tldp.org/LDP/abs/html/asciitable.html

MAX=256
OCT=8
OCTSQR=64

COLS=5

bigspace=-5
smallspace=-3

declare -i i=1
declare -i o=1

while [ "$i" -lt "$MAX" ]; do
	# printf "dec: %u oct: %o\n" $i $i

	paddingi="       $i"
	paddingo="  $o"
	# TODO: this formatting is broken

	# TODO: @-127 seems to work but most punctiation does not
	echo -ne "${paddingi: $bigspace}:"
	echo -ne "\\0${paddingo: $smallspace}"

	echo -n "       "

	# echo "decimal $i    octal $o"

	if (( i % "$COLS" == 0 )); then
		# new line
		echo
	fi

	i+=1
	o+=1

	if (( i % OCT == 0 )); then
		# do octal conversaion
		o=$o+2
	fi

	if (( i % OCTSQR == 0 )); then
		# more octal math
		o=$o+20
	fi
done

