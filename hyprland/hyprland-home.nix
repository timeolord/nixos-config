{ config, pkgs, userName, ... }:
let
  hyprland_base_config = builtins.readFile ./hyprland.conf;
  additional_config = builtins.readFile (./${userName}.conf);
  hyprland_config = hyprland_base_config + additional_config;
in
{
  imports = [
    ./kitty.nix
    ./waybar.nix
    ./dunst.nix
    ./hyprpaper.nix
    ./fuzzel.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = [ "--all" ];
    extraConfig = hyprland_config;
  };

  home.file.".config/sys64/power/style.css".source = ./syspower.css;

  home.packages = with pkgs; [
    hyprpolkitagent
    xdg-desktop-portal-gtk
    pavucontrol
    pipewire
    wireplumber
    hyprshot
  ];
}
