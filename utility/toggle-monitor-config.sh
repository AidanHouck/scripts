#!/usr/bin/env bash

# Used by Win+P on home desktop
# alacritty -o "window.dimensions.lines=15" -o "window.dimensions.columns=60" -e "/home/houck/scripts/utility/toggle-monitor-config.sh"

options=( "restart" "monitors" "monitors-1080" "single" "tv" "tv-1080" )

selection=$(for i in "${options[@]}"; do echo "$i"; done | fzf --layout=reverse-list --margin=5% --border --border-label="Select Input Method")

if [[ -z $selection ]]; then
	echo "Error: Input 'monitors', 'single', or 'tv' to select output"
	read -r
	exit 1


# Restart display manager
elif [[ $selection = 'restart' ]]; then
	sudo systemctl restart display-manager.service


# single monitor
elif [[ $selection = 'single' ]]; then
	xrandr --auto --verbose \
		--output DP-1 --mode 1920x1080 --rate 144 --primary \
		--output DP-2 --off \
		--output DP-4 --off \
		--output HDMI-0 --off


# 3 monitors native res
elif [[ $selection = 'monitors' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DP-1 --mode 1920x1080 --rate 144 --primary \
		--output DP-2 --mode 2560x1440 --scale 1 --rate 100 \
		--output DP-4 --mode 2560x1440 --scale 1 --rate 100 \
		--output HDMI-0 --off

	# Set positions
	xrandr --verbose \
		--output DP-1 --pos 0x1440 \
		--output DP-2 --pos 1920x1080 \
		--output DP-4 --pos 1920x0 --rotate inverted

# 3 monitors at matching scale
elif [[ $selection = 'monitors-1080' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DP-1 --mode 1920x1080 --rate 144 --primary \
		--output DP-2 --mode 2560x1440 --scale 0.75 --rate 100 \
		--output DP-4 --mode 2560x1440 --scale 0.75 --rate 100 \
		--output HDMI-0 --off

	# Set positions
	xrandr --verbose \
		--output DP-1 --pos 0x1080 \
		--output DP-2 --pos 1920x1080 \
		--output DP-4 --pos 1920x0 --rotate inverted


# 3 monitors + tv at native res
elif [[ $selection = 'tv' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DP-1 --mode 1920x1080 --rate 144 --primary \
		--output DP-2 --mode 2560x1440 --scale 1 --rate 100 \
		--output DP-4 --mode 2560x1440 --scale 1 --rate 100 \
		--output HDMI-0 --mode 3840x2160 --rate 60

	# Set positions
	xrandr --verbose \
		--output DP-1 --pos 0x1800 \
		--output DP-2 --pos 1920x1440 \
		--output DP-4 --pos 1920x0 --rotate inverted \
		--output HDMI-0 --pos 4480x720 --rotate normal

# 3 monitors + tv at matching scale
elif [[ $selection = 'tv-1080' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DP-1 --mode 1920x1080 --rate 144 --primary \
		--output DP-2 --mode 2560x1440 --scale 0.75 --rate 100 \
		--output DP-4 --mode 2560x1440 --scale 0.75 --rate 100 \
		--output HDMI-0 --mode 2560x1440 --rate 60

	# Set positions
	xrandr --verbose \
		--output DP-1 --pos 0x1080 \
		--output DP-2 --pos 1920x1080 \
		--output DP-4 --pos 1920x0 --rotate inverted \
		--output HDMI-0 --pos 3840x1080 --rotate normal

fi

