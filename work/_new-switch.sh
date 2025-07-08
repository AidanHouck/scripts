#!/usr/bin/env bash

set -euo pipefail

existing_dir() {
	find . -type d -print \
		| sed '1d; s_^./__g' \
		| fzf --header-first --header $'Select the directory to use\n───────\n' --layout=reverse --border
}

new_dir() {
	read -rp "Enter the new folder path to use: " dir
	echo "$dir"
}

# Gather switch directory
printf "%s\n" "Configuring new switch connection..."

printf "%s\n%s\n%s\n" \
	"Where will this switch go?" \
	"  1. An existing district/folder" \
	"  2. A new district/folder"

read -rp "(1/2): " choice
finish="-1"
directory=""
while [ "$finish" = "-1" ]; do
	case "$choice" in
	  1 ) directory=$(existing_dir); finish=1;;
	  2 ) directory=$(new_dir); mkdir -p "$directory"; finish=1;;
	  * ) read -rp "Invalid selection. (1/2): " choice;;
	esac
done

# Gather IP address
read -rp "Enter the IP of the device: " ip

# Gather hostname
read -rp "Enter the hostname of the device: " hostname

if [ -f "$directory/$hostname" ]; then
	read -rp "File '$directory/$hostname' already exists, overwrite contents? (y/N) " choice
	finish="-1"
	while [ "$finish" = "-1" ]; do
		case "$choice" in
		  y|Y ) break;;
		  n|N|"" ) echo "Exiting..."; exit 0;;
		  * ) echo ""; read -rp "Invalid selection. Overwrite file? (y/N) " choice;;
		esac
	done
fi

# Gather username
read -rp "Enter username to login with (n for none) [mveca]:" username

if [[ -z $username ]]; then
	# Default to "mveca" if you just press enter
	username="mveca"
elif [[ $username == "n" ]]; then
	# Set to none if you enter "n"
	username=""

	# Otherwise just use entered value
fi

# Gather SSH or Telnet
read -rp "SSH (1) or Telnet (2): " choice
finish="-1"
base=""
prompt=""
while [ "$finish" = "-1" ]; do
	case "$choice" in
	  1 ) base="ssh -oPreferredAuthentications=keyboard-interactive"; prompt=${username+"$username@"}; finish=1;;
	  2 ) base="telnet"; prompt=${username+"-l $username "}; finish=1;;
	  * ) read -rp "Invalid selection. (1/2): " choice;;
	esac
done

# If using ssh, ask what options are needed
if [[ $base == ssh* ]]; then
	printf "%s\n%s\n%s\n%s\n" \
		"How old is the device?" \
		"  1. Modern (No extra options)" \
		"  2. Old (DH Group 14 and RSA)" \
		"  3. Ancient (DH Group 1, RSA, CBC)"

	read -rp "([1]/2/3): " choice

	finish="-1"
	while [ "$finish" = "-1" ]; do
		case "$choice" in
		  1|"" ) finish=1;;
		  2 ) base="$base -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa"; finish=1;;
		  3 ) base="$base -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oCiphers=+aes256-cbc"; finish=1;;
		  * ) read -rp "Invalid selection. ([1]/2/3): " choice;;
		esac
	done
fi

# Write file contents
echo "echo \"$base $prompt$ip\" > \"$directory/$hostname\""
echo "$base $prompt$ip" > "$directory/$hostname"

