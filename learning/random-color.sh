#!/usr/bin/env bash

# Generate nice-looking random colors by clamping some of the ugly tones that purely random number generators tend to generate.

function rand () {
	# Generate a random number between max $1 and min $2
	min=$1
	max=$2
	shuf -i "${min}-${max}" -n1
}

h=$(rand 0 360)
s=$(rand 42 98)
l=$(rand 40 90)

echo "h $h"
echo "s $s"
echo "l $l"

echo "hsl(${h}, ${s}, ${l})"
echo preview: TODO:

