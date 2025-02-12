#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash openssh
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2b7c0dcdaab946153b0eaba5f2420f15ea27b0d6.tar.gz

echo "Entering ssh sub-shell..."
echo "'exit' to exit"
bash -i
