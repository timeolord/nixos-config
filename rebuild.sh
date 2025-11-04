#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash

sudo -- bash -c "nixos-rebuild switch --flake '/etc/nixos#melk'"
# Update Git Repo
cd /etc/nixos
git add -u
git commit -m "updated configs"
git push
