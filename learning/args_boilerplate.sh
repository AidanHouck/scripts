#!/usr/bin/env bash

# standard arg-parsing logic

function help () {
	echo "help"
	exit 1
}

# default case when 0 args
if [ $# -eq 0 ]; then
	help
fi

# parsing
while [ $# -gt 0 ] ; do
x="$1"; shift
case "$x" in
	-h|--help)
		help
		;;

	-v|--verbose)
		echo "verbose mode"
		;;

	-o|--output)
		OUTFILE="$1" ; shift ;
		echo "Output file is '$OUTFILE'"
		;;

	*)
		echo "Anything else!"
		;;

esac
done

