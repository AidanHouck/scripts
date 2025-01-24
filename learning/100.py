#!/usr/bin/env nix-shell
#! nix-shell -i python3
#! nix-shell -p python3

i = 0

while 1:
    i += 1
    print(i)
    if i == 100:
        exit()

