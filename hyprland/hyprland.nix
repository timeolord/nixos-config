{ config, pkgs, ... }:
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
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = with pkgs; [
    hyprpolkitagent
    xorg.xrandr
    xdg-desktop-portal-gtk
    pavucontrol
    pipewire
    wireplumber
  ];
}
