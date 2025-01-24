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
{
	sum += $4
	count += 1
}

END{
	print "Total is... " sum
	print "Count is... " count
	if (count > 0) print "Average is... " sum / count
}
' tmp



rm -f tmp

