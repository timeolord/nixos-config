{ config, lib, pkgs, userName, ... }:
let
  profiles = { current = ./current.nix; vespers = ./vespers.nix; };
in
{
  imports = builtins.attrValues profiles;

  options.style.name = lib.mkOption {
    type = lib.types.enum (builtins.attrNames profiles);
    default = import ./selected.nix;
    description = "Style profile applied on the next rebuild.";
  };

  config = {
    stylix = {
      enable = true;
      autoEnable = false;
      cursor = lib.mkDefault { package = pkgs.bibata-cursors; name = "Bibata-Modern-Ice"; size = 24; };
      targets.fontconfig.enable = true;
      targets.font-packages.enable = true;
      fonts = {
        serif = lib.mkDefault { package = pkgs.noto-fonts; name = "Noto Serif"; };
        sansSerif = lib.mkDefault { package = pkgs.noto-fonts; name = "Noto Sans"; };
        monospace = lib.mkDefault { package = pkgs.udev-gothic-nf; name = "UDEV Gothic NF"; };
        emoji = lib.mkDefault { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
        sizes = lib.mapAttrs (_: lib.mkDefault) { applications = 11; desktop = 12.75; popups = 10; terminal = 13; };
      };
    };

    home-manager.users.${userName} = { config, ... }: {
      stylix.targets = {
        fontconfig.enable = true;
        font-packages.enable = true;
        gtk.enable = lib.mkDefault true;
        qt.enable = lib.mkDefault true;
        kitty.enable = lib.mkDefault true;
        emacs.enable = lib.mkDefault true;
        hyprpaper.enable = true;
      };
      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
      };
      gtk.iconTheme = lib.mkDefault { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
      dconf.settings."org/gnome/desktop/interface" = {
        font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
        document-font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
        monospace-font-name = "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.applications}";
        color-scheme = if config.stylix.polarity == "light" then "prefer-light" else "prefer-dark";
      };
    };
  };
}
