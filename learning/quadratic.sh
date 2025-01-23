#!/usr/bin/env bash

# Give a, b, and c, solve a quadratic equation using the public heroku quadratic API

# TODO: this python is broken, rewrite this
exit 1

load() {
	echo $output | python3 -c "import sys, json; print(json.load(sys.stdin)['$1'])"
}

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
	echo "Usage: $0 a b c"
	echo "Where ax^2 + bx + c"
	exit -1
fi

output=$(curl -s "https://quadratic-solver-api.herokuapp.com/?a=$1&b=$2&c=$3")

if ! [[ $(echo $output | grep message) == "" ]]; then
	echo "Error: "$(load 'message')
	exit -1
fi

echo "The function is: "$(load 'function')
echo "The roots are "$(load 'roots' | awk '{print $2, $4}' | tr -d } | sed 's/,/ and/g')
echo "The vertex is "$(load 'vertex' | awk '{print $2, $4}' | tr -d })
echo "It opens "$(load 'parabolaOpening')

