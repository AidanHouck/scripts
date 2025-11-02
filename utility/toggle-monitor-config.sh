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


# single monitor
elif [[ $selection = 'single' ]]; then
	xrandr --auto --verbose \
		--output DP-2 --mode 2560x1440 --rate 100 --primary \
		--output DP-1 --off \
		--output HDMI-0 --off

# both monitors
elif [[ $selection = 'monitors' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DP-2 --mode 2560x1440 --rate 100 --primary \
		--output DP-1 --mode 2560x1440 --rate 100 \
		--output HDMI-0 --off

	# Set positions
	xrandr --verbose \
		--output DP-2 --pos 0x1440 \
		--output DP-1 --pos 0x0 --rotate inverted

# both monitors + tv
elif [[ $selection = 'tv' ]]; then
	# Set sizes
	xrandr --auto --verbose \
		--output DP-2 --mode 2560x1440 --rate 60 --primary \
		--output DP-1 --mode 2560x1440 --rate 60 \
		--output HDMI-0 --mode 3840x2160 --rate 60

	# Set positions
	xrandr --verbose \
		--output DP-2 --pos 3840x1440 \
		--output DP-1 --pos 3840x0 --rotate inverted \
		--output HDMI-0 --pos 0x1440 --rotate normal

fi

