#!/usr/bin/env bash

# Basic exploration of BEGIN{} /pattern/{} and BODY{} ideas in the AWK language

cat << EOF > tmp
1. Joe Big 2003
2. Carl White 2393
3. James Bing 3223
4. Boring Boro 2554
5. Another Line 1234
6. Last One 1002
EOF

awk '
BEGIN{
	# This happens at the beginning of execution
	printf "Num First Last Year\n"
}

/Carl/{
	# This happens when the pattern Carl matches
	print $4 "\t" $1 "\t" $3 "\t" $2
	next
}

{
	# This happens every line
	print $4 "\t" $1 "\t" $2 "\t" $3
}

END{
	# This happens at the end
	printf "And... Done\n"
}
' tmp



rm -f tmp

