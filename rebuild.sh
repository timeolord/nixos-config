#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash

cd /etc/nixos
git pull
sudo nixos-rebuild switch --flake /etc/nixos#${USER}
if [ $? -eq 0 ]; then
    # Update Git Repo
    git add -u
    git commit -m "updated configs"
    git push
else
    sudo nixos-rebuild switch --flake /etc/nixos#${USER} --show-trace
    git status
fi
