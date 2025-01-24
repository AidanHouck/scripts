#!/usr/bin/env bash

# Perform a whois lookup using whois.com and some gross HTML ""parsing""

if [[ $1 == "" ]]; then
        echo "Error: Please supply an argument to search for"
        exit 1
fi

input="$1"

# whois doesn't like www, remove it
if [[ "$input" =~ ^www\. ]]; then
	input=$(echo $input | sed 's/^www\.//g')
fi

output=$(curl -s "https://www.whois.com/whois/${input}" \
	-H 'authority: www.whois.com' \
	-H 'cache-control: max-age=0' \
	-H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
	-H 'sec-ch-ua-mobile: ?0' \
	-H 'sec-ch-ua-platform: "Windows"' \
	-H 'upgrade-insecure-requests: 1' \
	-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.81 Safari/537.36' \
	-H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
	-H 'sec-fetch-site: same-origin' \
	-H 'sec-fetch-mode: navigate' \
	-H 'sec-fetch-user: ?1' \
	-H 'sec-fetch-dest: document' \
	-H 'referer: https://www.whois.com/whois/' \
	-H 'accept-language: en-US,en;q=0.9' \
	-H 'cookie: whoissid=3vUCANdh3A34YAsycbpSTqv5%2FBgVSuH3v7MqwN%2BLvG37ziUZAyf6%2BgujPfyhLnGqs41AOhwzF3n69KLjHrYQYWzHQdtA8SDS93I4QUxLRloMrvhycIh%2FASF08Z05UHfwo9CwNjEWou7%2FhIwcF2jrqg40zh94qR1dPBhOInMD8FHL1pU4B2RqYguIKpagOWGCQd0IKnwVqhuUaBNOv0HYb64Q%2FLwZK3ImP9yQG5Z9qLhBD1aGZfceKvt17u%2FIdWEZQFIXFQDFZ%2BvYXKtvOeLAe9bXkSjvpoItB3mFKnnYR7v5QE6Pbpbf8Jn3yheeeWRkLWzcfWnnfj3dVT1ZyFLmBR7DifkItFsJDuRQsw0SaJ2ExNqdUB5L0GpSAOihza94Qsx6b9ba1UsJat4prTYw29dSnYKr30pM%2F3BP8aKXLlrKFZHsfTkMmcx2So8f7ezI0a5fAm%2FPnv3bzJuAd5I0UuTiw2Pi9wEtN22ap6tX2wwaRdLr4xpedmza7cIokj261JaAmEBHYhbOEcNfHCE%3D' \
	--compressed ;)

# initial filter (usually works for IP addresses)
cleaned_output=$(echo "$output" | grep "OrgName" | tail -n1 | cut -d' ' -f2-)

# if the above didn't work, try looking for something else (usually works for domains)
if [[ "$cleaned_output" == "" ]]; then
	cleaned_output=$(echo "$output" | grep "Organization:" | tail -n1 | cut -d' ' -f3-)
fi

# if nothing, error out instead of giving blank output
if [[ "$cleaned_output" == "" ]]; then
	echo Error: could not find any viable results for \""$1"\"
	exit 1
fi

echo "$input is owned by $cleaned_output"

