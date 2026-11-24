{ config, lib, pkgs, userName, ... }:
{
  config = lib.mkIf (config.style.name == "current") {
    stylix = {
      image = ../wallpapers/ivan_the_terrible.jpg;
      polarity = "dark";
      opacity = { terminal = 0.5; desktop = 0.5; popups = 0.5; applications = 0.95; };
      base16Scheme = {
        scheme = "current";
        author = "timeolord";
        base00 = "282828";
        base01 = "450693";
        base02 = "8c00ff";
        base03 = "838ba7";
        base04 = "928374";
        base05 = "f4d9e1";
        base06 = "f4d9e1";
        base07 = "ffffff";
        base08 = "ff3f7f";
        base09 = "f7768e";
        base0A = "ffc400";
        base0B = "9ece6a";
        base0C = "ffce00";
        base0D = "8c00ff";
        base0E = "595959";
        base0F = "24283b";
      };
      cursor = {
        name = "Sonic-cursor";
        size = 24;
        package = pkgs.runCommand "sonic-cursor" { } ''
          mkdir -p $out/share/icons
          ln -s ${pkgs.fetchzip {
            url = "https://github.com/K1NGSSTH/Sonic-cursor/releases/download/sonic-cursor/Sonic-cursor.tar";
            hash = "sha256-i7iOZT4mh7MtKeFN5/2Msm4ekTocdt9BIdXJfABv3aU=";
          }} $out/share/icons/Sonic-cursor
        '';
      };
    };

    home-manager.users.${userName} = { config, ... }: {
      # keep the existing app themes in this profile
      stylix.targets = {
        gtk.enable = false;
        qt.enable = false;
        kitty.enable = false;
        emacs.enable = false;
      };
      programs.kitty.settings.background_opacity = config.stylix.opacity.terminal;
      programs.waybar.style = lib.mkAfter ''
        * { font-family: UDEV Gothic NFLG, FontAwesome; }
        window#waybar { background: rgba(1, 1, 1, ${toString config.stylix.opacity.desktop}); }
      '';
      programs.emacs.extraConfig = ''
        (set-frame-parameter nil 'alpha-background ${toString (builtins.ceil (config.stylix.opacity.applications * 100))})
        (add-to-list 'default-frame-alist '(alpha-background . ${toString (builtins.ceil (config.stylix.opacity.applications * 100))}))
        (set-face-attribute 'default nil :family "${config.stylix.fonts.monospace.name}" :height ${toString (builtins.floor (config.stylix.fonts.sizes.terminal * 10))})
        (load-theme 'doom-one t)
      '';
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style = {
          name = "kvantum";
          package = [ pkgs.libsForQt5.qtstyleplugin-kvantum pkgs.qt6Packages.qtstyleplugin-kvantum ];
        };
      };
      xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=catppuccin-mocha-blue
      '';
      home.packages = [ (pkgs.catppuccin-kvantum.override { variant = "mocha"; accent = "blue"; }) ];
      gtk = {
        enable = true;
        font = { name = config.stylix.fonts.monospace.name; size = config.stylix.fonts.sizes.applications; };
        theme = {
          name = "catppuccin-mocha-blue-standard";
          package = pkgs.catppuccin-gtk.override { variant = "mocha"; accents = [ "blue" ]; };
        };
        gtk4.theme = config.gtk.theme;
      };
    };
  };
}
