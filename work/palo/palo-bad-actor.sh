#!/usr/bin/env bash

# Interact with Palo Alto API for SOC alerts
set -eou pipefail

# Check if anyone else has a lock
check_pan_lock() {
	# Check config lock
	while read_xml; do
		if [[ $ENTITY =~ entry.+ ]]; then
			echo "$ENTITY->$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST 'https://'"${PANO}"'/api?type=op&cmd=<show><config-locks></config-locks></show>' \
		-s)

	# Check commit lock
	while read_xml; do
		if [[ $ENTITY =~ entry.+ ]]; then
			echo "$ENTITY->$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST 'https://'"${PANO}"'/api?type=op&cmd=<show><commit-locks></commit-locks></show>' \
		-s)
}

# Create a new object
create_pan_object() {
	while read_xml; do
		if [[ $ENTITY =~ response.+ ]]; then
			echo "$ENTITY"
		elif [[ $ENTITY = msg ]]; then
			echo "$ENTITY->$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=config" \
		--data-urlencode "action=set" \
		--data-urlencode "xpath=${xpath_value}" \
		--data-urlencode "element=${element_value}" \
		-s)
}

# Add pan object to existing rule
add_pan_object_to_rule() {
	while read_xml; do
		if [[ $ENTITY =~ response.+ ]]; then
			echo "$ENTITY"
		elif [[ $ENTITY = msg ]]; then
			echo "$ENTITY->$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=config" \
		--data-urlencode "action=set" \
		--data-urlencode "xpath=${xpath_value}" \
		--data-urlencode "element=${element_value}" \
		-s)
}

# Fetch the current audit comment on the rule.
# It will either be blank or "Add 1.1.1.1, 1.1.1.2" etc
get_pan_rule_audit_comment() {
	while read_xml; do
		if [[ $ENTITY = comment ]]; then
			echo "$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=op" \
		--data-urlencode "cmd=${cmd_value}" \
		-s)
}

# Update audit comment for rule
update_pan_rule_audit_comment() {
	while read_xml; do
		if [[ $ENTITY =~ response.+ ]]; then
			echo "$ENTITY"
		elif [[ $ENTITY = msg ]]; then
			echo "$ENTITY->$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=op" \
		--data-urlencode "cmd=${cmd_value}" \
		-s)
}

# Preview panorama config diff
commit_changes() {
	while read_xml; do
		if [[ $ENTITY =~ response.+ ]]; then
			echo "$ENTITY"
		elif [[ $ENTITY = line ]]; then
			echo "$CONTENT"
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST "https://${PANO}/api" \
		--data-urlencode "type=commit" \
		--data-urlencode "cmd=<commit-all></commit-all>" \
		-s)
}

# Lookup given IP via bgp.tools API
# https://bgp.tools/kb/api
# bgp_tools_lookup 1.2.3.4
bgp_tools_lookup() {
	local output
	output=$(whois -h bgp.tools " -v ${ip}" | tail -n +2 | cut -d"|" -f3,7 | tr -d "\n")

	subnet=$(cut -d"|" -f1 <<< "$output" | tr -d " ")
	name=$(cut -d"|" -f2 <<< "$output" | awk '{$1=$1;print}' | tr -cd 'a-zA-Z0-9 _\-\.')
}

# Query logs with given filter and number of logs
# query_logs (addr.src in '1.2.3.4') 1
query_logs() {
	local job=""
	local query="${1}"
	local nlogs="${2}"
	local was_error=

	# Request log job and save the job ID
	while read_xml; do
		if [[ $ENTITY = "job" ]]; then
			job="${CONTENT}"
		elif [[ $ENTITY =~ response.+error.+ ]]; then
			echo "ERROR: $ENTITY" 1>&2
			was_error=1
		elif [[ $was_error ]] && [[ $ENTITY = "line" ]]; then
			echo "$ENTITY: $CONTENT" 1>&2
		fi
	done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
		-X POST 'https://'"${PANO}"'/api' \
		--data-urlencode "type=log" \
		--data-urlencode "log-type=traffic" \
		--data-urlencode "nlogs=${nlogs}" \
		--data-urlencode "query=${query}" \
		-s)

	# If there was an error then exit script
	if [[ $was_error ]]; then
		return 1
	fi

	# If we did not get a job ID then fail
	if [[ -z "${job}" ]]; then
		echo "ERROR: Failed to get job-id for log lookup request!"
		return 1
	fi

	# Request logs using job ID
	sleep 1s
	local loop=1
	while [[ $loop != 0 ]]; do
		loop=0
		while read_xml; do
			# Status is active so it's not ready yet
			if [[ $ENTITY = "status" ]]; then
				if [[ $CONTENT = "ACT" ]]; then
					loop=1
					printf "." 1>&2
					sleep 1.5s
					break
				fi
			elif [[ $ENTITY =~ response.+error.+ ]]; then
				echo "ERROR: $ENTITY" 1>&2
				was_error=1
			elif [[ $was_error ]] && [[ $ENTITY = "msg" ]]; then
				echo "$ENTITY: $CONTENT" 1>&2
			elif [[ $ENTITY = "time_generated" ]] ||
			[[ $ENTITY = "src" ]] ||
			[[ $ENTITY = "dst" ]] ||
			[[ $ENTITY = "rule" ]] ||
			[[ $ENTITY =~ srcloc.+ ]] ||
			[[ $ENTITY = "sessionid" ]] ||
			[[ $ENTITY = "dport" ]] ||
			[[ $ENTITY = "proto" ]] ||
			[[ $ENTITY = "action" ]] ||
			[[ $ENTITY = "pkts_received" ]]; then
				echo "$ENTITY,$CONTENT"
			fi
		done < <(curl -H "X-PAN-KEY: $(cat "$PALO_API")" \
			-X POST 'https://'"${PANO}"'/api' \
			--data-urlencode "type=log" \
			--data-urlencode "action=get" \
			--data-urlencode "job-id=${job}" \
			-s)
	done

	# If there was an error then exit script
	if [[ $was_error ]]; then
		return 1
	fi

	# Clear ...'s when done
	printf "\r\e[K" 1>&2
}

# Dump XML response values
# dump_xml $(curl)
dump_xml() {
	while read_xml; do
		if ! [[ ${ENTITY:0:1} = "/" ]] && # First char of key is not "/"
		[[ -n "${ENTITY}" ]] &&           # Key is not blank
		[[ -n "${CONTENT}" ]]; then       # Key Value is not blank
			echo "$ENTITY -> $CONTENT"
		fi
	done < <("$1")
}

# Helper function for parsing XML
read_xml () {
	local IFS=\>
	read -rd \< ENTITY CONTENT
}

main () {
	ip="${1}"

	# Request a single log to check if it matches the existing rule
	response=$(query_logs "(addr.src in '${ip}')" 1)

	if [[ -z "${response}" ]]; then
		echo "Error: No traffic found from IP ${ip}!"
		return 0
	fi

	rule=$(grep -E "rule,.+" <<< "$response")
	already_dropped=
	if [[ $rule = "rule,Drop identified bad actors" ]]; then
		already_dropped=1
	else
		# Save dport, proto, and country to use later
		dport=$(sed -n "s/^dport,\(\S*\).*$/\1/p" <<< "$response")
		dport_proto=$(sed -n "s/^proto,\(\S*\).*$/\1/p" <<< "$response")
		srcloc=$(sed -n "s/^srcloc.*,\(.*\).*$/\1/p" <<< "$response")

		# Check packets received with meaningful amounts of data
		response=$(query_logs "(addr.src in '${ip}') and (pkts_received geq '4')" 1)
		no_data_returned=
		if [[ -z $response ]]; then
			no_data_returned=1
		fi

		# Loop and check for ports used
		dport_list="${dport_proto}/${dport}"
		dport_filter="(port.dst neq '${dport}')"
		found_all_ports=

		for (( i=0; i<5; i++ )); do
			response=$(query_logs "(addr.src in '${ip}') and ${dport_filter}" 1)
			if [[ -z $response ]]; then
				# No more ports found, we are done
				found_all_ports=1
				i=5
				continue
			else
				dport=$(sed -n "s/^dport,\(\S*\).*$/\1/p" <<< "$response")
				dport_proto=$(sed -n "s/^proto,\(\S*\).*$/\1/p" <<< "$response")
				dport_list="${dport_list}, ${dport_proto}/${dport}"
				dport_filter="${dport_filter} and (port.dst neq '${dport}')"
			fi
		done

		# There were more than 5 ports used
		random_ports=
		if [[ -z "${found_all_ports}" ]]; then
			random_ports=1
		fi

		# Query bgp.tools for subnet/name
		subnet=""
		name=""
		bgp_tools_lookup "${ip}"

		# Cleanup invalid characters
		name=$(echo "$name" | tr -cd '[:alnum:]\. \-_')
		name_len=$(( ${#name} + ${#subnet} + 1 ))

		# Name is too long, truncate
		if [[ $name_len -gt 63 ]]; then
			name=$(head -c $(( ${#name} - 7 )) <<<"$name")
		fi

		# Check if we may not want to drop the whole subnet
		display_name=
		dont_drop=
		if [[ $srcloc =~ ^.*United\ States.*$ ]] ||
		[[ $srcloc =~ ^.*USA.*$ ]] ||
		[[ $name =~ ^.*Amazon.*$ ]] ||
		[[ $name =~ ^.*AWS.*$ ]] ||
		[[ $name =~ ^.*Microsoft.*$ ]] ||
		[[ $name =~ ^.*Google.*$ ]] ||
		[[ $name =~ ^.*GCP.*$ ]]; then
			display_name=1 # If they are of note then add the name to SOC display
			if [[ -n "${random_ports}" ]]; then
				echo -n "Random ports"
			else
				echo -n "${dport_list}"
			fi

			echo -n " from ${name} in ${srcloc}."

			if [[ -n "${no_data_returned}" ]]; then
				echo -n " No data returned. "
			fi
			echo ""

			echo "Destination IPs accessed:"
			response=$(query_logs "(addr.src in '${ip}')" 100)
			dst=$(sed -n "s/^dst,\(.*\).*$/\1/p" <<< "$response")
			echo "${dst}" | sort -n | uniq

			read -rp "Drop ${subnet}(1), ${ip}(2), or None(3)? (1/2/3) " choice
			finish="-1"
			while [ "$finish" = "-1" ]; do
				case "$choice" in
				  1 ) finish=1;;
				  2 ) subnet=${ip}; finish=1;;
				  3 ) dont_drop=1; finish=1;;
				  * ) read -rp "Invalid selection. (1/2/3) " choice;;
				esac
			done
		fi

		obj_name="${name}-${subnet/\//_}"
	fi

	# Print SOC response to console
	echo "-----------------------"
	echo "SOC Reponse"
	echo "-----------------------"
	response=""
	if [[ -n "${already_dropped}" ]]; then
		response=${response}"1. Subnet already being dropped.\n"
		response=${response}$(./palo-object-search.sh "${1}")""

		echo -e "${response}" | tee >(/mnt/c/Windows/system32/clip.exe)
		echo -e "\nCopied to clipboard"

		return 0
	elif [[ -n "${dont_drop-}" ]]; then
		response=${response}"1. Benign"

		echo -e "${response}" | tee >(/mnt/c/Windows/system32/clip.exe)
		echo -e "\nCopied to clipboard"

		return 0
	else
		if [[ -n "${random_ports}" ]]; then
			response=${response}"5. Random ports from "
		else
			response=${response}"5. ${dport_list} from "
		fi
		if [[ -n "${display_name}" ]]; then
			response=${response}"${name} "
		fi
		response=${response}"${srcloc}. "
		if [[ -n "${no_data_returned}" ]]; then
			response=${response}"No data returned. "
		fi
		response=${response}"Rule updated.\n"
		response=${response}"${subnet}"

		echo -e "${response}" | tee >(/mnt/c/Windows/system32/clip.exe)
		echo -e "\nCopied to clipboard"
	fi

	# Create object
	num_changes=$((num_changes+1))
	xpath_value="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='On-Prem-DG']/address/entry[@name='${obj_name}']"
	element_value="<description>${ip}</description><tag><member>Bad-Actor</member></tag><ip-netmask>${subnet}</ip-netmask>"

	echo ""
	read -rp "Create object '${obj_name}'? (y/n) " choice
	finish="-1"
	while [ "$finish" = "-1" ]; do
		case "$choice" in
		  y|Y ) echo "Creating object..."; create_pan_object; finish=1;;
		  n|N ) echo "Exiting..."; return 0;;
		  * ) echo ""; read -rp "Invalid selection. Create object? (y/n) " choice;;
		esac
	done

	# Fetch current audit comment
	xpath_value="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='On-Prem-DG']/pre-rulebase/security/rules/entry[@name='Drop identified bad actors']"
	cmd_value="<show><config><list><audit-comments><xpath>${xpath_value}</xpath></audit-comments></list></config></show>"
	current=$(get_pan_rule_audit_comment)

	# Add new subnet to rule
	xpath_value="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='On-Prem-DG']/pre-rulebase/security/rules/entry[@name='Drop identified bad actors']/source"
	element_value="<member>${obj_name}</member>"
	echo ""
	echo "Adding object to bad actor rule..."
	add_pan_object_to_rule

	# Update audit comment
	if [[ -z $current ]]; then
		# If the audit comment is blank, start with "Add ..."
		audit_comment="Add ${subnet}"
	else
		# It is not blank, append subnet
		audit_comment="${current}, ${subnet}"
	fi

	xpath_value="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='On-Prem-DG']/pre-rulebase/security/rules/entry[@name='Drop identified bad actors']"
	cmd_value="<set><audit-comment><xpath>${xpath_value}</xpath><comment>${audit_comment}</comment></audit-comment></set>"
	echo ""
	echo "Updating audit comment"
	update_pan_rule_audit_comment
}

# Define constants
readonly PALO_USER='.palo_user'
readonly PALO_API='.palo_api'
readonly PALO_FQDN='.palo_fqdn'

PANO="$(cat "${PALO_FQDN}")"
readonly PANO

num_changes=0

# Verify needed files exists
if [[ ! -f "${PALO_USER}" ]]; then
	echo "ERROR: $PALO_USER does not exist!"
	echo "echo username > $PALO_USER"
	exit 1
fi

if [[ ! -f "${PALO_FQDN}" ]]; then
	echo "ERROR: $PALO_FQDN does not exist!"
	echo "echo panorama.fqdn.tld > $PALO_FQDN"
	exit 1
fi

# Generate/verify API key
./palo-api-key.sh

# Check lock before continuing
lock=$(check_pan_lock)
if [[ -n $lock ]]; then
	user=$(sed -n "s/^.*\"\(\S*\)\".*$/\1/p" <<< "$lock")
	if [[ $user = $(cat $PALO_USER) ]]; then
		echo "There is a lock but it is me ($user), continue."
	else
		echo "User $user has a lock, not making any changes."
		exit 0
	fi
else
	echo "No Panorama locks found"
fi

if [ $# -eq 0 ]; then
	# No IP provided, loop and gather user input
	read -rp "Enter IP to search (n to exit): " input
	finish="-1"
	while : ; do
		if [[ $input =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
			main "${input}"
			input=""
		elif [[ "${input,,}" = "n" ]]; then
			break
		else
		  read -rp "Enter IP to search (n to exit): " input
		fi
	done
else
	# IP provided, run just the one command
	main "${1}"
fi

if [[ $num_changes -gt 0 ]]; then
	# Preview diff
	read -rp "Preview diff? (y/n) " choice
	finish="-1"
	while [ "$finish" = "-1" ]; do
		case "$choice" in
		  y|Y ) ./palo-config-audit.sh; finish=1;;
		  n|N ) echo "Skipping diff..."; finish=1;;
		  * ) echo ""; read -rp "Invalid selection. Preview diff? (y/n) " choice;;
		esac
	done

	# Commit changes
	read -rp "Commit changes? (y/n) " choice
	finish="-1"
	while [ "$finish" = "-1" ]; do
		case "$choice" in
		  y|Y ) commit_changes; exit 0;;
		  n|N ) echo "Exiting..."; exit 0;;
		  * ) echo ""; read -rp "Invalid selection. Commit changes? (y/n) " choice;;
		esac
	done
fi

