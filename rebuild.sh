#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash

cd /etc/nixos
git pull
sudo -- bash -c "nixos-rebuild switch --flake '/etc/nixos#${USER}'"
# Update Git Repo
git add -u
git commit -m "updated configs"
git push
