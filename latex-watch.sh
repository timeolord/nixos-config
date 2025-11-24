#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash texliveFull

latexmk -pdf -pvc -view=none
