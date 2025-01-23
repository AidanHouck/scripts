#!/usr/bin/env bash

# Emulate the functionality of grep through regular expressions

# ./script -a = echo a a
# ./script a = echo a at end of file
# ./script -g = echo idk
# ./script what = echo $@

opts="n l i v x"

FLAG_LINENUMS=
FLAG_FILENAME=
FLAG_CASEINSR=
FLAG_DOINVERT=
FLAG_FULLLINE=

while getopts "$opts" flag; do
	case $flag in
		n)  # -n: print line numbers in output
			FLAG_LINENUMS=1
			;;

		l)	# -l: print the names of files with one+ matching lines
			FLAG_FILENAME=1
			;;

		i)	# -i: case-insensitive matching
			FLAG_CASEINSR=1
			;;

		v)	# -v: invert the matching
			FLAG_DOINVERT=1
			;;

		x)	# -x: only match full lines
			FLAG_FULLLINE=1
			;;

		?) echo Example parameters:
		   echo -n: display line numbers
		   echo -l: print file names with any matching lines
		   echo -i: case-insensitive
		   echo -v: invert matching rules
		   echo -x: only match full lines
		   exit 1
		   ;;
	esac
done
shift $((OPTIND - 1))

regex=$1
input=$(echo "$@" | cut -d' ' -f2)
allInput=$(echo "$@" | cut -d' ' -f3-)
totalInput=$(echo "$allInput"| wc -w)
totalInput=$((totalInput + 1))

# Validation
if [ -z "$regex" ]; then
	echo Error: Please supply both a string to search for and one or more file names to search through
	exit 1
fi

if [ -z "$input" ]; then
	echo Error: Please supply a file name
	exit 1
fi

if ! [ -a "$input" ]; then
	echo Error: File \""$input"\" not found
	exit 1
fi

# Full-line flag
if [ -n "$FLAG_FULLLINE" ]; then
	regex=^${regex}$
fi

while ! [[ $input == "" ]]; do
	# Start reading a file
	i=1
	foundMatch=false
	while read -r line; do
		# lineCount=$(wc -l "$input" | cut -d' ' -f 1)
		lineCompare=$line

		# Case-insensitive flag
		if [ -n "$FLAG_CASEINSR" ]; then
			regex=$( echo "$regex" | tr '[:upper:]' '[:lower:]' )
			lineCompare=$( echo "$line" | tr '[:upper:]' '[:lower:]' )
		fi

		if [ -n "$FLAG_FILENAME" ]; then
			# Inverted matching pattern flag
			if [ -n "$FLAG_DOINVERT" ]; then
				if ! [[ $lineCompare =~ ($regex) ]]; then
					foundMatch=true
				fi
			else
				if [[ $lineCompare =~ ($regex) ]]; then
					foundMatch=true
				fi
			fi
		else
			# Formatting if we're using multiple files or not
			if [[ $totalInput -gt 1 ]]; then
				inputDisplay="$input:"
			else
				inputDisplay=""
			fi

			# Inverted matching pattern flag
			if [ -n "$FLAG_DOINVERT" ]; then
				if ! [[ $lineCompare =~ ($regex) ]]; then
					# Line numbering in output flag
					if [ -n "$FLAG_LINENUMS" ]; then
						echo "$input:$i: $line"
					else
						echo "$input: $line"
					fi
				fi
			else
				if [[ $lineCompare =~ ($regex) ]]; then
					# Line numbering in output flag
					if [ -n "$FLAG_LINENUMS" ]; then
						echo "${inputDisplay}${line}"
					else
						echo "${inputDisplay}${line}"
					fi
				fi
			fi
			i=$((i + 1))
		fi
	done < "$input"

	if [[ $foundMatch == true ]]; then
		echo "$input"
	fi

	# If more files were input, start to process them
	if [[ $(echo "$allInput" | wc -w) -gt 1 ]]; then
		input=$(echo "$allInput" | cut -d' ' -f1)
		allInput=$(echo "$allInput" | cut -d' ' -f2-)
	elif [[ $(echo "$allInput" | wc -w) -eq 1 ]]; then
		input=$allInput
		allInput=""
	else
		input=""
	fi
done

