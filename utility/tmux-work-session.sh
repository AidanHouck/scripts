#!/usr/bin/env bash

# Setup standard tmux working environment

NAME="work"
tmux has-session -t $NAME &>/dev/null

if [ $? != 0 ]; then
	tmux new-session -s $NAME -d \; send-keys 'cd ~/ssh.d/' C-m
	tmux split-window -h \; send-keys 'cd ~/src/nix-config && git status' C-m \; rename-window "main"
	tmux new-window \; send-keys 'cd ~/scripts/work/palo' C-m \; rename-window "palo"

	tmux select-window -t 1
fi

tmux attach -t $NAME
