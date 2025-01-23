#!/usr/bin/env bash

# Encode the given string using the ancient 'atbash' cipher technique

# Letters are transposed with a reverse alphabet. E.G.:
#	a -> z, test -> gvhg, gvhg -> test

upperOffsetLow=101
upperOffsetHigh=132
lowerOffsetLow=141
lowerOffsetHigh=172
zVal=31

if [ -z "$1" ]; then
        echo "Error: Please text to be ciphered"
        exit 1
fi

# loop through every char in the input
for (( i=0; i<${#1}; i++ )); do
	# Echo the char into its octal ascii value
	val=$(echo -ne "${1:$i:1}" | hexdump -b | sed 's/[^[:blank:]]*[[:blank:]]*//' | head -n1 | head -c 3)

	# Check which range (upper/lowercase) we are in
	if [ "$val" -le $upperOffsetHigh ] && [ "$val" -ge $upperOffsetLow ]; then
	    # UPPERCASE

		# Normalize 0-25
		val=$((val - upperOffsetLow))

		# Do offset math
		val=$((zVal - val))

		# Un-normalize for printing
		val=$((val + upperOffsetLow))

	elif [ "$val" -le $lowerOffsetHigh ] && [ "$val" -ge $lowerOffsetLow ]; then
		# lowercase

		# Normalize 0-25
		val=$((val - lowerOffsetLow))

		# Do offset math
		val=$((zVal - val))

		# Un-normalize for printing
		val=$((val + lowerOffsetLow))

	else
		# not alphabetic character
		true
	fi

	# Octal sanity check hack
	if [[ $(echo "$val" | tail -c 2 | head -c 1) -gt 4 ]]; then
		val=$((val - 2))
	fi

	# shellcheck disable=SC2059
	printf "\\$val"
done
echo

