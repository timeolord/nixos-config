#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash notify-desktop

pkill dunst
dunst &

notify-desktop -u critical "Test message: critical test 1"
notify-desktop -u normal "Test message: normal test 2"
notify-desktop -u low "Test message: low test 3"
notify-desktop -u critical "Test message: critical test 4"
notify-desktop -u normal "Test message: normal test 5"
notify-desktop -u low "Test message: low test 6"
notify-desktop -u critical "Test message: critical test 7"
notify-desktop -u normal "Test message: normal test 8"
notify-desktop -u low "Test message: low test 9"
