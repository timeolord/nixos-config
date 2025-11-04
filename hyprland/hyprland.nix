{ config, pkgs, ... }:
{
  imports = [
    ./kitty.nix
    ./waybar.nix
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./hyprland.conf;
  };
}
