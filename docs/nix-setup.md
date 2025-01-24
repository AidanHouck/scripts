# nix

// Install Nix
// https://nix.dev/install-nix#install-nix
// Windows->WSL2->Systemd Support version

```
sudo bash -i
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

// Restart shell
nix --version
nix-shell -p nix-info --run "nix-info -m"

// Create new nix-shell environment with
// the cowsay package installed
nix-shell -p cowsay
cowsay h
exit

// Create the new environment and run a
// one-shot command, then exit
nix-shell -p cowsay --run "cowsay H"

// Search for packages on:
// https://search.nixos.org/packages

// Create environment and specify the
// source as a specific git revision
nix-shell -p git --run "git --version" --pure -I nixpkgs=https://github.com/NixOS/nixpkgs/tarball/2a601aafdc5605a5133a2ca506a34a3a73377247

// Cleanup Cache
nix-collect-garbage

## Bash NixOS script
```
#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash cacert curl jq python3Packages.xmljson
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2a601aafdc5605a5133a2ca506a34a3a73377247.tar.gz

curl https://github.com/NixOS/nixpkgs/releases.atom | xml2json | jq .
```

Meaning:
	- `-i bash` = use bash as interpreter for the rest of the script
	- `--pure` = ignore most environment variables (prefer nixos packages to $PATH)
	- `-p x y z` = packages required to run
	- `-I nixpkgs=...` = pin versions of all packages to a specific commit in the Nixpkgs GitHub repo

```
chmod +x
./nixpkgs-releases.sh
```

## Check size of nix dir
du -hcd 0 /nix

