#!/usr/bin/env nix-shell
#! nix-shell -i bash gparted xhost
#! nix-shell -p bash

xhost +SI:localuser:root
sudo gparted
