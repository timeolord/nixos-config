{ config, pkgs, userName, ... }:
let
  hyprland_base_config = builtins.readFile ./hyprland.lua;
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
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = [ "--all" ];
    configType = "lua";
    extraConfig = hyprland_config;
  };

  # home.pointerCursor = {
  #   name = "Sonic";
  #   size = 24;
  #   # package = null;
  #   gtk.enable = true;
  #   x11.enable = true;
  #   # hyprcursor.enable = true;
  # };

    home.pointerCursor =
    let
      getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          hyprcursor.enable = true;
          name = name;
          size = 24;
          enable = true;
          package =
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom
        "https://github.com/K1NGSSTH/Sonic-cursor/releases/download/sonic-cursor/Sonic-cursor.tar"
        "sha256-i7iOZT4mh7MtKeFN5/2Msm4ekTocdt9BIdXJfABv3aU="
        "Sonic-cursor";

  home.sessionVariables = {
    # GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=Default
    Default Layout=us
    DefaultIM=keyboard-us

    [Groups/0/Items/0]
    Name=keyboard-us
    Layout=

    [Groups/0/Items/1]
    Name=keyboard-fr
    Layout=

    [Groups/0/Items/2]
    Name=pinyin
    Layout=

    [GroupOrder]
    0=Default
  '';

  # xdg.configFile."fcitx5/config".text = ''
  #   [Hotkey]
  #   TriggerKeys=Super+space
  #   EnumerateForwardKeys=
  #   EnumerateBackwardKeys=
  # '';

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
