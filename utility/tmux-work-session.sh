#!/usr/bin/env bash

# Setup standard tmux working environment

NAME="work"
tmux has-session -t $NAME &>/dev/null

if [ $? != 0 ]; then
	# Top-left
	tmux new-session -s $NAME -d \; send-keys 'cd ~/scripts/ && git fetch && git status' C-m
	tmux send-keys 'cd work/palo/ && ./palo-api-key.sh' C-m

	# Top-middle
	tmux split-window -h \; send-keys 'cd ~/src/nix-config && git fetch && git status' C-m \; rename-window "main"

	# Right column
	# tmux split-window -h \; send-keys 'cd /mnt/o/Aidan/Notes && vim r_todo.txt' C-m

	# Bottom-middle
	#tmux select-pane -L
	tmux split-window -v \; send-keys 'cd /mnt/o/Network\ Info/ && tree -dL 1' C-m

	# Bottom-left
	tmux select-pane -L
	tmux split-window -v \; send-keys 'cd /mnt/o/Aidan/Notes && tree -dL 2' C-m

	# Set sizing
	#tmux select-layout 'e3ed,211x54,0,0{83x54,0,0[83x26,0,0,0,83x27,0,27,4],83x54,84,0[83x26,84,0,1,83x27,84,27,3],43x54,168,0,2}'
fi

tmux attach -t $NAME
