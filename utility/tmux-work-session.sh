#!/usr/bin/env bash

# Setup standard tmux working environment

NAME="work"
tmux has-session -t $NAME &>/dev/null

if [ $? != 0 ]; then
	# Top-left
	tmux new-session -s $NAME -d \; send-keys 'cd ~/ssh.d && ls' C-m

	# Top-right
	tmux split-window -h \; send-keys 'cd ~/src/nix-config && git status' C-m \; rename-window "main"

	# Bottom-right
	tmux split-window -v \; send-keys 'cd ~/scripts/work/palo && git status && ./palo-api-key.sh' C-m

	# Bottom-left
	tmux select-pane -L
	tmux split-window -v \; send-keys 'cd /mnt/o/Aidan/Notes && ll Processes/' C-m
fi

tmux attach -t $NAME
