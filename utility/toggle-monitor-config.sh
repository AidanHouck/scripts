#!/usr/bin/env bash

# Used by Win+P on home desktop
# alacritty -o "window.dimensions.lines=15" -o "window.dimensions.columns=60" -e "/home/houck/scripts/utility/toggle-monitor-config.sh"

options=( "restart" "monitors" "single" "tv" )

selection=$(for i in "${options[@]}"; do echo "$i"; done | fzf --layout=reverse-list --margin=5% --border --border-label="Select Input Method")

if [[ -z $selection ]]; then
	echo "Error: Input 'monitors', 'single', or 'tv' to select output"
	read -r
	exit 1

# Restart display manager
elif [[ $selection = 'restart' ]]; then
	sudo systemctl restart display-manager.service

# 3 monitors
elif [[ $selection = 'monitors' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DVI-D-0 --mode 1920x1080 --rate 144 --primary \
		--output DP-0 --mode 2560x1440 --scale 0.75x0.75 --rate 100 \
		--output HDMI-0 --mode 2560x1440 --scale 0.75x0.75 --rate 100

	# Set positions
	xrandr --verbose \
		--output DVI-D-0 --pos 0x1080 \
		--output DP-0 --pos 1920x1080 \
		--output HDMI-0 --pos 1920x0 --rotate inverted

# single monitor
elif [[ $selection = 'single' ]]; then
	xrandr --auto --verbose \
		--output DVI-D-0 --mode 1920x1080 --rate 144 --primary \
		--output DP-0 --off \
		--output HDMI-0 --off

# 2 monitors + tv
elif [[ $selection = 'tv' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DVI-D-0 --mode 1920x1080 --rate 60 --primary \
		--output DP-0 --mode 2560x1440 --scale 0.75x0.75 --rate 60 \
		--output HDMI-0 --mode 2560x1440 --rate 60

	# Set positions
	xrandr --verbose \
		--output DVI-D-0 --pos 0x0 \
		--output DP-0 --pos 1920x0 \
		--output HDMI-0 --pos 3840x0 --rotate normal

fi

