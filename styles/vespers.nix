{ config, lib, pkgs, userName, ... }:
{
  config = lib.mkIf (config.style.name == "vespers") {
    stylix = {
      image = ../wallpapers/abbey_in_the_oakwood.jpg;
      polarity = "dark";
      base16Scheme = {
        scheme = "Vespers";
        author = "timeolord";
        base00 = "211a16";
        base01 = "2e241d";
        base02 = "453529";
        base03 = "8b7560";
        base04 = "b6a38b";
        base05 = "e8dfce";
        base06 = "f2ebdd";
        base07 = "faf6ec";
        base08 = "c47b73";
        base09 = "cb9868";
        base0A = "d8bb78";
        base0B = "a8ad86";
        base0C = "98ada0";
        base0D = "c9a45c";
        base0E = "b59aaf";
        base0F = "a98167";
      };
      fonts = {
        serif = { package = pkgs.eb-garamond; name = "EB Garamond"; };
        sansSerif = { package = pkgs.eb-garamond; name = "EB Garamond"; };
        monospace = { package = pkgs.nerd-fonts.iosevka-term; name = "IosevkaTerm Nerd Font"; };
        sizes = { applications = 13; desktop = 11; popups = 13; terminal = 13; };
      };
      opacity = { applications = 1.0; desktop = 0.98; popups = 1.0; terminal = 0.97; };
    };

    home-manager.users.${userName} = { config, ... }:
    let
      colors = config.lib.stylix.colors;
      force_values = lib.mapAttrs (_: lib.mkForce);
      render_style = import ./render.nix { inherit config lib; };
    in
    {
      home.packages = [ pkgs.cinzel ];
      desktop = {
        language_labels = {
          keyboard-us = "ANGLICA";
          keyboard-us-intl = "GALLICA";
          pinyin = "SINICA";
          mozc = "IAPONICA";
          keyboard-tr = "TURCICA";
        };
        language_tooltip = "Lingua · preme ad proximam · preme dextra ad priorem";
        language_unavailable = "Lingua non praesto est";
      };

      wayland.windowManager.hyprland.extraConfig = lib.mkAfter (render_style (builtins.readFile ./vespers/hyprland.lua));

      programs.waybar = {
        style = lib.mkForce (render_style (builtins.readFile ./vespers/waybar.css));
        settings.mainBar = {
          margin-top = lib.mkForce 12;
          margin-left = lib.mkForce 18;
          margin-right = lib.mkForce 18;
          height = 42;
          spacing = 0;
          modules-left = lib.mkForce [ "custom/sigil" "ext/workspaces" ];
          modules-center = lib.mkForce [ "clock#date" "clock" ];
          modules-right = lib.mkForce [ "cpu" "memory" "network" "pulseaudio" "custom/language" "battery" "tray" "custom/power" ];
          "custom/sigil" = { format = "VESPERAE"; tooltip-format = "Ad maiorem Dei gloriam"; };
          "ext/workspaces".format-icons = lib.mkForce {
            "1" = "I"; "2" = "II"; "3" = "III"; "4" = "IV"; "5" = "V";
            "6" = "VI"; "7" = "VII"; "8" = "VIII"; "9" = "IX"; "10" = "X";
            urgent = "!";
          };
          clock = { format = lib.mkForce "{:%H:%M}"; };
          "clock#date".format = lib.mkForce "{:%d · %m · %Y}";
          cpu.format = lib.mkForce "CALC {usage}%";
          memory.format = lib.mkForce "MEM {}%";
          network = force_values {
            format-wifi = "RETE";
            format-ethernet = "RETE";
            format-linked = "RETE";
            format-disconnected = "RETE ×";
            tooltip-format = "{ifname}\n{ipaddr}\n↓ {bandwidthDownBytes}   ↑ {bandwidthUpBytes}";
          };
          pulseaudio = force_values { format = "VOX {volume}%"; format-muted = "SILENTIUM"; };
          battery = force_values {
            format = "VIS {capacity}%";
            format-charging = "VIS +{capacity}%";
            format-plugged = "VIS {capacity}%";
          };
          tray = { icon-size = lib.mkForce 16; spacing = lib.mkForce 8; };
          "custom/power" = { format = lib.mkForce "EXIRE"; tooltip-format = "Finis sessionis"; };
        };
      };

      programs.fuzzel.settings = {
        main = {
          font = "EB Garamond:size=16";
          prompt = "Quaere: ";
          width = 48;
          lines = 10;
          horizontal-pad = 28;
          vertical-pad = 22;
          inner-pad = 12;
        };
        border = { width = 2; radius = 3; };
        colors = force_values {
          background = "${colors.base00}ff";
          text = "${colors.base05}ff";
          prompt = "${colors.base0D}ff";
          placeholder = "${colors.base04}ff";
          input = "${colors.base06}ff";
          match = "${colors.base0A}ff";
          selection = "${colors.base02}ff";
          selection-text = "${colors.base07}ff";
          selection-match = "${colors.base0A}ff";
          counter = "${colors.base04}ff";
          border = "${colors.base0D}ff";
        };
      };

      services.dunst.settings = {
        global = force_values {
          font = "EB Garamond 14";
          width = 380;
          offset = "(24, 76)";
          padding = 20;
          horizontal_padding = 24;
          frame_width = 2;
          frame_color = "#${colors.base0D}";
          separator_height = 1;
          separator_color = "#${colors.base02}";
          corner_radius = 3;
          format = "<b>%s</b>\n%b";
        };
        urgency_low = force_values { background = "#${colors.base00}ff"; foreground = "#${colors.base04}ff"; };
        urgency_normal = force_values { background = "#${colors.base00}ff"; foreground = "#${colors.base05}ff"; };
        urgency_critical = force_values { background = "#${colors.base00}ff"; foreground = "#${colors.base06}ff"; frame_color = "#${colors.base08}"; };
      };

      programs.kitty.settings = {
        window_padding_width = 20;
        cursor_shape = "beam";
        cursor_blink_interval = 0;
        inactive_text_alpha = "0.85";
        tab_bar_style = "separator";
        tab_separator = "  │  ";
        active_tab_font_style = "bold";
      };
      programs.emacs.extraConfig = lib.mkAfter (builtins.readFile ./vespers/emacs.el);
      programs.fish.interactiveShellInit = lib.mkAfter (render_style (builtins.readFile ./vespers/prompt.fish));
      stylix.targets.fish.enable = true;
      stylix.targets.gtk.extraCss = ''
        window decoration { border: 1px solid #${colors.base0D}; }
        button { border-radius: 3px; }
        selection { background-color: #${colors.base02}; color: #${colors.base07}; }
      '';
      home.file.".config/sys64/power/style.css".source = pkgs.writeText "vespers-power.css" (render_style (builtins.readFile ./vespers/power.css));
    };
  };
}
