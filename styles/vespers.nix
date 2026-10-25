{ config, lib, pkgs, inputs, userName, ... }:
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
        sansSerif = { package = pkgs.terminus_font_ttf; name = "Terminus (TTF)"; };
        monospace = { package = pkgs.terminus_font_ttf; name = "Terminus (TTF)"; };
        sizes = { applications = 15; desktop = 15; popups = 15; terminal = 15; };
      };
      opacity = { applications = 1.0; desktop = 1.0; popups = 1.0; terminal = 1.0; };
    };

    home-manager.users.${userName} = { config, ... }:
    let
      colors = config.lib.stylix.colors;
      force_values = lib.mapAttrs (_: lib.mkForce);
      render_style = import ./render.nix { inherit config lib; };
      cross_icon = pkgs.writeText "vespers-cross.svg" (render_style (builtins.readFile ./vespers/cross.svg));
      flat_qt = pkgs.runCommand "vespers-flat-kvantum" { nativeBuildInputs = [ pkgs.libxslt ]; } ''
        theme_dir=$out/share/Kvantum/Base16Kvantum
        mkdir -p "$theme_dir"
        xsltproc ${./vespers/flat_qt.xsl} ${colors {
          template = builtins.readFile "${inputs.stylix}/modules/qt/kvantum.svg.mustache";
          extension = ".svg";
        }} > "$theme_dir/Base16Kvantum.svg"
        cp ${colors {
          template = builtins.readFile "${inputs.stylix}/modules/qt/kvconfig.mustache";
          extension = ".kvconfig";
        }} "$theme_dir/Base16Kvantum.kvconfig"
        substituteInPlace "$theme_dir/Base16Kvantum.kvconfig" \
          --replace-fail 'menu_shadow_depth=7' 'menu_shadow_depth=0' \
          --replace-fail 'popup_blurring=true' 'popup_blurring=false' \
          --replace-fail 'reduce_window_opacity=10' 'reduce_window_opacity=0' \
          --replace-fail 'shadowless_popup=false' 'shadowless_popup=true' \
          --replace-fail 'transient_scrollbar=true' 'transient_scrollbar=false' \
          --replace-fail 'blur_konsole=true' 'blur_konsole=false' \
          --replace-fail 'blur_translucent=true' 'blur_translucent=false'
      '';
    in
    {
      home.packages = [ pkgs.cinzel ];
      xdg.configFile."fontconfig/conf.d/99-vespers-pixel.conf".text = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <match target="font">
            <test name="family" compare="eq"><string>Terminus (TTF)</string></test>
            <edit name="antialias" mode="assign"><bool>false</bool></edit>
          </match>
        </fontconfig>
      '';
      qt.kvantum.themes = lib.mkForce [ flat_qt ];
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
        style = lib.mkForce (builtins.replaceStrings [ "@cross_asset@" ] [ "${cross_icon}" ] (render_style (builtins.readFile ./vespers/waybar.css)));
        settings.mainBar = {
          margin-top = lib.mkForce 8;
          margin-left = lib.mkForce 12;
          margin-right = lib.mkForce 12;
          height = 48;
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
          tray = { icon-size = lib.mkForce 20; spacing = lib.mkForce 8; };
          "custom/power" = { format = lib.mkForce "EXIRE"; tooltip-format = "Finis sessionis"; };
        };
      };

      programs.fuzzel.settings = {
        main = {
          font = "Terminus (TTF):pixelsize=${toString (config.stylix.fonts.sizes.popups * 4 / 3)}:antialias=false";
          prompt = "Quaere: ";
          width = 48;
          lines = 10;
          horizontal-pad = 20;
          vertical-pad = 16;
          inner-pad = 8;
        };
        border = { width = 3; radius = 0; };
        colors = force_values {
          background = "${colors.base00}ff";
          text = "${colors.base05}ff";
          prompt = "${colors.base0D}ff";
          placeholder = "${colors.base04}ff";
          input = "${colors.base06}ff";
          match = "${colors.base0A}ff";
          selection = "${colors.base0A}ff";
          selection-text = "${colors.base00}ff";
          selection-match = "${colors.base00}ff";
          counter = "${colors.base04}ff";
          border = "${colors.base0D}ff";
        };
      };

      services.dunst.settings = {
        global = force_values {
          font = "Terminus (TTF) ${toString config.stylix.fonts.sizes.popups}";
          width = 460;
          offset = "(24, 84)";
          padding = 16;
          horizontal_padding = 16;
          frame_width = 3;
          frame_color = "#${colors.base0D}";
          separator_height = 1;
          separator_color = "#${colors.base02}";
          corner_radius = 0;
          format = "<b>%s</b>\n%b";
        };
        urgency_low = force_values { background = "#${colors.base00}ff"; foreground = "#${colors.base04}ff"; };
        urgency_normal = force_values { background = "#${colors.base00}ff"; foreground = "#${colors.base05}ff"; };
        urgency_critical = force_values { background = "#${colors.base00}ff"; foreground = "#${colors.base06}ff"; frame_color = "#${colors.base08}"; };
      };

      programs.kitty.settings = {
        window_padding_width = 12;
        cursor_shape = "block";
        cursor_blink_interval = 0;
        inactive_text_alpha = "1.0";
        tab_bar_style = "separator";
        tab_separator = "  │  ";
        active_tab_font_style = "bold";
      };
      programs.emacs.extraConfig = lib.mkAfter (builtins.readFile ./vespers/emacs.el);
      programs.fish.interactiveShellInit = lib.mkAfter (render_style (builtins.readFile ./vespers/prompt.fish));
      stylix.targets.fish.enable = true;
      stylix.targets.gtk.extraCss = ''
        * { border-radius: 0; box-shadow: none; text-shadow: none; transition: none; animation: none; }
        window decoration { border: 2px solid #${colors.base0D}; }
        button, entry, spinbutton, combobox, menu, popover, tooltip, headerbar, notebook > header, trough, progress, slider {
          background-image: none;
        }
        button { background-color: #${colors.base01}; border: 2px solid #${colors.base03}; }
        button:hover { border-color: #${colors.base0D}; }
        button:active, button:checked { background-color: #${colors.base0A}; color: #${colors.base00}; border-color: #${colors.base0A}; }
        entry { border: 2px solid #${colors.base03}; }
        entry:focus { border-color: #${colors.base0D}; }
        selection { background-color: #${colors.base0A}; color: #${colors.base00}; }
      '';
      home.file.".config/sys64/power/style.css".source = pkgs.writeText "vespers-power.css" (render_style (builtins.readFile ./vespers/power.css));
    };
  };
}
