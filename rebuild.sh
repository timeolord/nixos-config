#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash

sudo git config --global --add safe.directory /etc/nixos
sudo -- bash -c "nixos-rebuild switch --flake '/etc/nixos#melktogo'"
# Update Git Repo
cd /etc/nixos
git add -u
git commit -m "updated configs"
git push
