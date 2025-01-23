#!/usr/bin/env bash

# Progress bar implementation. change $iterations and $delay to customize

ITERATIONS=35
DELAY="0.05"

iter=$((ITERATIONS + 1))
incr=$((100 / (iter - 1)))
bar=""
stat=0

for i in $(seq $iter); do
	bar="${bar} "
done

for i in $(seq $iter); do
	printf "%s%s%%" "$bar" "$stat"
	sleep $DELAY

	bar="#"${bar:0:-1}

	stat=$((stat + incr))
	if [[ "$i" -eq "$((iter - 1))" ]]; then
		# last iteration, round to 100
		stat=100
	fi

	printf "\r"
done

printf "\nDone\n"

