#!/usr/bin/env bash

# Display info about a given IP address / subnet range

usage() {
	# Display the usage / help text and exit the program
	echo "\
This script displays basic info about IPv4 address and subnets.

Example usage:
$0 -h # Display this help message
$0 -w # Enable whois lookups on public IP addresses
$0 -a 192.168.1.1 # Show info about a particular address
$0 -a 10.10.2.0/24 # Show info about a subnet in CIDR notation
$0 -a 200.100.120.45 -m 255.255.255.252 # Show info about a subnet in dotted decimal notation"
	exit 1
}

verify-addr() {
	# Given a dotted-decimal address, validate it is legitimate
	addr="$1"

	# Check for 4 decimals
	if [ "$( echo "$addr" | tr -cd '.' | wc -c )" -ne 3 ]; then
		echo Error: IP address does not have 4 separate octets in dotted decimal notation
		exit 1
	fi

	# Assign everything between each period to a variable, ignoring any possible CIDR notation
	addr2=$(echo "$addr" | sed 's/\/.*$//g')
	separate "$addr2" "address"

	# Check each octet is a number in the right range
	i=0
	while [ "$i" -lt "4" ]; do
		octet=${addrOctet[$i]}

		# Check is a number
		if ! echo "$octet" | grep -q -e '[0-9]'; then
			echo Error: IP address octet "$i" "$octet" is not a number
			exit 1
		fi

		# Check is within a valid range
		if [ "$octet" -lt "0" ] || [ "$octet" -gt "255" ]; then
			echo Error: IP address octet "$i" "$octet" is not 0 through 255
			exit 1
		fi

		i=$((i+1))
	done
}

verify-mask() {
	# Given a dotted-decimal subnet mask, validate it is legitimate
	mask="$1"

	# Check for 4 decimals
	if [ "$( echo "$mask" | tr -cd '.' | wc -c )" -ne 3 ]; then
		echo Error: Subnet mask does not have 4 octets in dotted decimal notation
		exit 1
	fi

	# Assign everything between each period to a variable, ignoring any possible CIDR notation
	separate "$mask" "mask"

	# Check each octet is a valid number
	i=0
	FLAG_NEXT_IS_0=
	while [ "$i" -lt "4" ]; do
		octet=${maskOctet[$i]}

		# Check is a number
		if ! echo "$octet" | grep -q -e '[0-9]'; then
			echo Error: Subnet mask octet "$i" "$octet" is not a number
			exit 1
		fi

		# Check is within a valid range
		if [ "$octet" -lt "0" ] || [ "$octet" -gt "255" ]; then
			echo Error: Subnet mask octet "$i" "$octet" is not a number between 0 and 255
			exit 1
		fi

		# Check is an allowed value
		if ! echo "$octet" | grep -Eq "^0$|^128$|^192$|^224$|^240$|^248$|^252$|^254$|^255$"; then
			echo Error: Subnet mask octet "$i" "$octet" is an invalid number that cannot be a subnet mask
			exit 1
		fi


		if [ -n "$FLAG_NEXT_IS_0" ] && [ "$octet" -ne 0 ]; then
			echo Error: Subnet mask bits are not in descending order
			exit 1
		fi

		if [ "$octet" -ne 255 ]; then
			# If anything but 255, next digit must be 0
			FLAG_NEXT_IS_0=true
		fi

		i=$((i+1))
	done
}

cidr-split() {
	# If the given address is in CIDR notation, split it into an address and mask, then return the decimal mask
	addr="$1"

	if echo "$addr" | grep -q '/'; then
		cidr=$(echo "$addr" | sed 's/^.*\///g')

		if ! echo "$cidr" | grep -q -e '^[0-9]*$'; then
			echo Error: CIDR value "$cidr" is not a number
			exit 1
		fi

		# Check is within a valid range
		if [ "$cidr" -lt "0" ] || [ "$cidr" -gt "32" ]; then
			echo Error: CIDR value "$cidr" is not in the range 0-32
			exit 1
		fi

		# fill out mask octets based on CIDR given
		i=0
		maskValues=( 0 128 192 224 240 248 252 254 )
		cidr_i=$cidr
		while :; do
			if [ "$cidr_i" -ge 8 ]; then
				maskOctet[i]=255
				cidr_i=$((cidr_i-8))
			else
				maskOctet[i]=${maskValues[$cidr_i]}
				break
			fi
			i=$((i+1))
		done

		# remove the cidr from global var $address
		address=$(echo "$address" | sed 's/\/.*$//g')

		# don't forget to build the full $mask string, other functions look at that for validation
		mask=${maskOctet[0]}.${maskOctet[1]}.${maskOctet[2]}.${maskOctet[3]}
	elif [ -n "$mask" ]; then
		# If no `/x` given check if we have a mask
		# verify mask is valid & split to array
		verify-mask "$mask"

		# fill out mask octets based on CIDR given
		i=0
		cidr=0
		while :; do
			# TODO: this sucks do this better
			if [ "${maskOctet[$i]}" -eq 255 ]; then
				cidr=$((cidr+8))
			elif [ "${maskOctet[$i]}" -eq 254 ]; then
				cidr=$((cidr+7))
			elif [ "${maskOctet[$i]}" -eq 252 ]; then
				cidr=$((cidr+6))
			elif [ "${maskOctet[$i]}" -eq 248 ]; then
				cidr=$((cidr+5))
			elif [ "${maskOctet[$i]}" -eq 240 ]; then
				cidr=$((cidr+4))
			elif [ "${maskOctet[$i]}" -eq 224 ]; then
				cidr=$((cidr+3))
			elif [ "${maskOctet[$i]}" -eq 192 ]; then
				cidr=$((cidr+2))
			elif [ "${maskOctet[$i]}" -eq 128 ]; then
				cidr=$((cidr+1))
			elif [ "${maskOctet[$i]}" -eq 0 ]; then
				break
			fi

			i=$((i+1))
		done
	elif [ -z "$cidr" ]; then
		# No cidr or mask defined, assume /32
		cidr=32
	fi
}

separate() {
	# Given a dotted-decimal address, separate it into 4 separate variables
	addr="$1"
	addressType="$2"

	i=0
	while [ "$i" -lt "4" ]; do
		value="$(echo "$addr" | cut -d'.' -f "$((i+1))")"

		if [ "$addressType" == "address" ]; then
			addrOctet[i]="$value"
		elif [ "$addressType" == "mask" ]; then
			maskOctet[i]="$value"
		else
			echo "Error in func separate()!!" && exit 1
		fi

		i=$((i+1))
	done
}

echo_public_address () {
	# State whether or not $address is public or reserved
	# Ref: https://datatracker.ietf.org/doc/html/rfc5735#section-4

	# RFC 1918
	# 10.0.0.0/8
	if [[ ${addrOctet[0]} -eq 10 ]] && [[ $cidr -ge 8 ]]; then
		echo "$address" is part of the 10.0.0.0/8 range reserved for \"Private-Use networks\" by RFC 1918
		return
	fi

	# 172.16.0.0/12
	if [[ ${addrOctet[0]} -eq 172 ]] && [[ ${addrOctet[1]} -ge 16 ]] && [[ ${addrOctet[1]} -le 31 ]] && [[ $cidr -ge 16 ]]; then
		echo "$address" is part of the 172.16.0.0/12 range reserved for \"Private-Use networks\" by RFC 1918
		return
	fi

	# 192.168.0.0/16
	if [[ ${addrOctet[0]} -eq 192 ]] && [[ ${addrOctet[1]} -eq 168 ]] && [[ $cidr -ge 16 ]]; then
		echo "$address" is part of the 192.168.0.0/16 range reserved for \"Private-Use networks\" by RFC 1918
		return
	fi

	# RFC 1122
	# 127.0.0.0/8
	if [[ ${addrOctet[0]} -eq 127 ]] && [[ $cidr -ge 8 ]]; then
		echo "$address" is part of the 127.0.0.0/8 range reserved for \"Loopback\" by RFC 1122
		return
	fi

	# 0.0.0.0/8
	if [[ ${addrOctet[0]} -eq 0 ]] && [[ $cidr -ge 8 ]]; then
		echo "$address" is part of the 0.0.0.0/8 range reserved for \"\"This\" Network\" by RFC 1122
		return
	fi

	# 240.0.0.0/4
	if [[ ${addrOctet[0]} -ge 240 ]] && [[ $cidr -ge 4 ]]; then
		echo "$address" is part of the 240.0.0.0/4 range reserved for \"Future use\" by RFC 1122
		return
	fi

	# RFC 3927
	# 169.254.0.0/16
	if [[ ${addrOctet[0]} -eq 169 ]] && [[ ${addrOctet[1]} -eq 254 ]] && [[ $cidr -ge 16 ]]; then
		echo "$address" is part of the 169.254.0.0/16 range reserved for \"Link Local\" by RFC 3927
		return
	fi

	# RFC 5736
	# 192.0.0.0/24
	if [[ ${addrOctet[0]} -eq 192 ]] && [[ ${addrOctet[1]} -eq 0 ]] && [[ ${addrOctet[2]} -eq 0 ]] && [[ $cidr -ge 24 ]]; then
		echo "$address" is part of the 192.0.0.0/24 range reserved for \"IETF Protocol Assignments\" by RFC 5736
		return
	fi

	# RFC 5737
	# 192.0.2.0/24
	if [[ ${addrOctet[0]} -eq 192 ]] && [[ ${addrOctet[1]} -eq 0 ]] && [[ ${addrOctet[2]} -eq 2 ]] && [[ $cidr -ge 24 ]]; then
		echo "$address" is part of the 192.0.2.0/24 range reserved for \"TEST-NET-1\" by RFC 5737
		return
	fi

	# 198.51.100.0/24
	if [[ ${addrOctet[0]} -eq 192 ]] && [[ ${addrOctet[1]} -eq 51 ]] && [[ ${addrOctet[2]} -eq 100 ]] && [[ $cidr -ge 24 ]]; then
		echo "$address" is part of the 192.51.100.0/24 range reserved for \"TEST-NET-2\" by RFC 5737
		return
	fi

	# 203.0.113.0/24
	if [[ ${addrOctet[0]} -eq 203 ]] && [[ ${addrOctet[1]} -eq 0 ]] && [[ ${addrOctet[2]} -eq 113 ]] && [[ $cidr -ge 24 ]]; then
		echo "$address" is part of the 203.0.113.0/24 range reserved for \"TEST-NET-3\" by RFC 5737
		return
	fi

	# RFC 3068
	# 192.88.99.0/24
	if [[ ${addrOctet[0]} -eq 192 ]] && [[ ${addrOctet[1]} -eq 88 ]] && [[ ${addrOctet[2]} -eq 99 ]] && [[ $cidr -ge 24 ]]; then
		echo "$address" is part of the 192.88.99.0/24 range reserved for \"6to4 Relay Anycast\" by RFC 3068
		return
	fi

	# RFC 2544
	# 192.18.0.0/15
	if [[ ${addrOctet[0]} -eq 192 ]] && [[ ${addrOctet[1]} -ge 18 ]] && [[ ${addrOctet[1]} -le 19 ]] && [[ $cidr -ge 15 ]]; then
		echo "$address" is part of the 192.18.0.0/15 range reserved for \"Private-Use networks\" by RFC 2544
		return
	fi

	# RFC 3171
	# 224.0.0.0/4
	if [[ ${addrOctet[0]} -ge 224 ]] && [[ ${addrOctet[0]} -le 239 ]] && [[ $cidr -ge 4 ]]; then
		echo "$address" is part of the 224.0.0.0/4 range reserved for \"Multicast\" by RFC 3171
		return
	fi

	# RFC 919, 922
	# 255.255.255.255/32
	if [[ ${addrOctet[0]} -eq 255 ]] && [[ ${addrOctet[1]} -eq 255 ]] && [[ ${addrOctet[2]} -eq 255 ]] && [[ ${addrOctet[3]} -eq 255 ]] && [[ $cidr -eq 32 ]]; then
		echo "$address" is part of the 255.255.255.255/32 range reserved for \"Limited Broadcast\" by RFC 919 and 922
		return
	fi

	# Publicly routable
	echo "$address" is a public address.
	FLAG_IS_PUBLIC="true"
}

echo_subnetting () {
	# Perform and display results of subnetting operations on $address with $mask
	network_addr=
	broadcast_addr=
	num_addrs=

	i=0
	while [ "$i" -lt "4" ]; do
		# Net mask, first address
		# for each octet, if 255 keep the same
		if [[ ${maskOctet[$i]} -eq "255" ]]; then
			network_addr=${network_addr}.${addrOctet[$i]}
			broadcast_addr=${broadcast_addr}.${addrOctet[$i]}

		# if 0 set to 0
		elif [[ ${maskOctet[$i]} -eq "0" ]]; then
			network_addr=${network_addr}.0
			broadcast_addr=${broadcast_addr}.255

		# else mask is not 255 or 0,
		else
			# Find the number of addresses as defined by the mask
			#  e.g. 255=1, 192=64, etc
			diff=$((256 - ${maskOctet[$i]}))

			oct=0
			# Loop to find what value we need to use
			while [ "$oct" -le "${addrOctet[$i]}" ]; do
				oct=$((oct + diff))
			done

			# Build address piecemeal
			network_addr=${network_addr}.$((oct-diff))
			broadcast_addr=${broadcast_addr}.$((oct-1))
		fi

		# Usage range, net mask + 1 to broadcast -1

		i=$((i+1))
	done

	# Tidy up IP addresses
	network_addr=${network_addr:1}
	broadcast_addr=${broadcast_addr:1}
	num_addrs=$((2 ** (32 - cidr)))

	# display
	echo The network address is "$network_addr"
	echo The broadcast address is "$broadcast_addr"
	echo There are "$num_addrs" addresses in the subnet \($((num_addrs - 2)) usable\)
}

if [ -z "$1" ]; then
	usage
fi

address=
addrOctet=( 0 0 0 0 )

mask=
maskOctet=( 0 0 0 0 )

while getopts ":a:m:hw" arg; do
	case "${arg}" in
		a)
			address=${OPTARG}
			;;
		m)
			mask=${OPTARG}
			;;
		h)
			usage
			;;
		w)
			FLAG_DO_WHOIS="true"
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

# Clean up input data into easier-to-use variable
cidr=
cidr-split "$address"

verify-addr "$address"

# Display useful info to the user about their entered address
FLAG_IS_PUBLIC=
echo Info about IP address "${addrOctet[0]}.${addrOctet[1]}.${addrOctet[2]}.${addrOctet[3]}":
echo_public_address

# If address is public, do a whois lookup on it
if [ -n "$FLAG_IS_PUBLIC" ]; then
	# Check whois file exists
	if [ -a "./whois.sh" ] && [ -n "$FLAG_DO_WHOIS" ]; then
		./whois.sh "$address"
	fi
fi

if [ -n "$mask" ] && [ "$cidr" -lt 32 ]; then
	echo Subnet mask "${maskOctet[0]}.${maskOctet[1]}.${maskOctet[2]}.${maskOctet[3]}" is valid, "$cidr" in CIDR notation
	echo_subnetting
fi

