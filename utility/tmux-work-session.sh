#!/usr/bin/env bash

# Setup standard tmux working environment

NAME="work"
tmux has-session -t $NAME &>/dev/null

if [ $? != 0 ]; then
	# Top-left
	tmux new-session -s $NAME -d \; send-keys 'cd ~/ssh.d/ && tree -dL 1' C-m

	# Top-middle
	tmux split-window -h \; send-keys 'cd ~/src/nix-config && git fetch && git status' C-m \; rename-window "main"

	# Bottom-middle
	tmux split-window -v \; send-keys 'cd /mnt/o/Network\ Info/ && tree -dL 1' C-m

	# Bottom-left
	tmux select-pane -L
	tmux split-window -v \; send-keys 'cd /mnt/o/aidan/notes && tree -dL 2' C-m
fi

tmux attach -t $NAME
