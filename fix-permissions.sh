#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash

sudo setfacl -R -m u:${USER}:rwx /etc/nixos
