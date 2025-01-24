#!/usr/bin/env bash

ps aux | awk '

BEGIN {
	printf "Processes owned by user \"houck\":\n"
} 

NR==1 { print }

$1 ~ /houck/ {
	print
	i++ 
}

END {
	printf i " out of " NF " total"
}
'

