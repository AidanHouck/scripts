#!/usr/bin/env bash

# Given $1, determine whether or not it is a leap year

if [ -z "$1" ]; then
	echo "Error: Please input a year to be checked"
	exit 1
fi

expression='^[+-]?[0-9]+$'
if ! [[ $1 =~ $expression ]]; then
	echo "Error: Please enter a valid number"
	exit 1
fi

if [ "$1" -lt 0 ]; then
	echo "Error: Please input a non-negative year"
	exit 1
fi

isLeapYear=false

# Every year divisible by 4 is a leap year
if [ $(($1 % 4)) -eq 0 ]; then
	isLeapYear=true
	
	# ... unless it is divisible by 100
	if [ $(($1 % 100)) -eq 0 ]; then
		isLeapYear=false
		
		# ... unless it is also divisible by 400
		if [ $(($1 % 400)) -eq 0 ]; then	
			isLeapYear=true
		fi
	fi
fi

if [ $isLeapYear == true ]; then
	echo "$1 is a leap year"
else
	echo "$1 is not a leap year"
fi

