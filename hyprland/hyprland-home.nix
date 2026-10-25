{ config, lib, pkgs, userName, ... }:
let
  render_style = import ../styles/render.nix { inherit config lib; };
  hyprland_base_config = render_style (builtins.readFile ./hyprland.lua);
  additional_config = builtins.readFile (./${userName}.lua);
  hyprland_config = hyprland_base_config + additional_config;
in
{
  imports = [
    ./kitty.nix
    ./waybar.nix
    ./dunst.nix
    ./hyprpaper.nix
    ./fuzzel.nix
    ./input-method.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = [ "--all" ];
    configType = "lua";
    extraConfig = hyprland_config;
  };

  home.sessionVariables = {
    # GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  home.file.".config/sys64/power/config.conf".source = ./syspower.conf;
  home.file.".config/sys64/power/style.css".source = ./syspower.css;

  home.packages = with pkgs; [
    hyprpolkitagent
    xdg-desktop-portal-gtk
    pavucontrol
    pipewire
    wireplumber
    hyprshot
    networkmanagerapplet
    brightnessctl
  ];
}
