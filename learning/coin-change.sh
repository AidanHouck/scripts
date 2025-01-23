#!/usr/bin/env bash

# Given a $1 number of cents, output the correct distribution
# of coins to use proper change using as few coins as possible

# TODO: consider some coin-agnostic refactor approach. if I want to add a new set of coins it becomes very annoying

c_penny=0
c_nickel=0
c_dime=0
c_quarter=0

runningChange="$1"

if [ -z "$1" ]; then
	echo "Error: Please enter a value, in cents, to calculate"
	exit 1
fi

expression='^[-]?[0-9]+$'
if ! [[ $1 =~ $expression ]]; then
        echo "Error: Please enter a valid whole number"
        exit 1
fi

if [ "$1" -lt 0 ]; then
	echo "Error: Please enter a positive number"
	exit 1
fi


# main loop
while [ "$runningChange" -ne 0 ]; do
	# Quarter
	if [ "$runningChange" -ge 25 ]; then
		runningChange=$((runningChange - 25))
		c_quarter=$((c_quarter+1))
		continue
	fi

	# Dime
	if [ "$runningChange" -ge 10 ]; then
		runningChange=$((runningChange - 10))
		c_dime=$((c_dime+1))
		continue
	fi

	# Nickel
	if [ "$runningChange" -ge 5 ]; then
		runningChange=$((runningChange - 5))
		c_nickel=$((c_nickel+1))
		continue
	fi

	# Else, penny
	runningChange=$((runningChange-1))
	c_penny=$((c_penny+1))
done

# Output
echo "$1 cents of change is:"

if [ "$c_quarter" -eq 1 ]; then
	echo "$c_quarter quater"
elif [ "$c_quarter" -eq 0 ]; then
	true
else
	echo "$c_quarter quaters"
fi

if [ "$c_dime" -eq 1 ]; then
	echo "$c_dime dime"
elif [ "$c_dime" -eq 0 ]; then
	true
else
	echo "$c_dime dimes"
fi

if [ "$c_nickel" -eq 1 ]; then
	echo "$c_nickel nickel"
elif [ "$c_nickel" -eq 0 ]; then
	true
else
	echo "$c_nickel nickels"
fi

if [ "$c_penny" -eq 1 ]; then
	echo "$c_penny penny"
elif [ "$c_penny" -eq 0 ]; then
	true
else
	echo "$c_penny pennies"
fi

