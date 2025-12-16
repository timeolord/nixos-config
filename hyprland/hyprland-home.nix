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

  home.file.".config/sys64/power/style.css".source = ./syspower.css;

  home.packages = with pkgs; [
    hyprpolkitagent
    xdg-desktop-portal-gtk
    pavucontrol
    pipewire
    wireplumber
    hyprshot
    networkmanagerapplet
  ];
}
