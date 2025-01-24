#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash cowsay nix-info
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2a601aafdc5605a5133a2ca506a34a3a73377247.tar.gz
# shellcheck shell=bash

cowsay "$(nix-info -m)"

