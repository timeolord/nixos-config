#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash

sudo nix-collect-garbage -d
nix-collect-garbage -d
sudo nix-store --optimise
