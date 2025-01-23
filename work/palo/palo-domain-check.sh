#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo Usage:
	echo - Add URL to search
	echo - "'./palo-domain-check www.google.com'"
	exit 1
fi

URL="$1"
REQUEST=$(curl -s "https://urlfiltering.paloaltonetworks.com/single_cr/?url=$URL")

NL=$'\n'
# shellcheck disable=SC2086
echo $REQUEST |\
	grep -Pzo '"POST"(.|\n)*</form>' |\
	sed 's/<label class="control-label col-sm-2 col-lg-2 " for="id_new_category">/'"\\${NL}"'/g' |\
	sed 's;</label> <div class=" col-sm-10 col-lg-10 form-text">;:;g' |\
	sed 's; </div> </div>.*;;g' |\
	sed '1d;$d'

