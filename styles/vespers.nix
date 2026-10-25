{ config, lib, pkgs, inputs, userName, ... }:
{
  config = lib.mkIf (config.style.name == "vespers") {
    stylix = {
      image = ../wallpapers/abbey_in_the_oakwood.jpg;
      polarity = "dark";
      targets.console.enable = true;
      cursor = { package = pkgs.hackneyed; name = "Hackneyed"; size = 24; };
      base16Scheme = {
        scheme = "Vespers";
        author = "timeolord";
        base00 = "36261e";
        base01 = "443124";
        base02 = "58402f";
        base03 = "a08a70";
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

    console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v24n.psf.gz";
    services.displayManager.ly.settings = {
      animation = "none";
      auth_fails = 0;
      full_color = false;
      bg = "0x00000001";
      fg = "0x00000008";
      border_fg = "0x01000004";
      error_bg = "0x00000001";
      error_fg = "0x01000002";
      box_title = "VESPERAE";
      initial_info_text = "AD MAIOREM DEI GLORIAM";
      hide_borders = false;
      blank_box = true;
      margin_box_h = 4;
      margin_box_v = 2;
      input_len = 36;
      edge_margin = 2;
      text_in_center = true;
      bigclock = "none";
      clock = "%H:%M";
    };

    home-manager.users.${userName} = { config, ... }:
    let
      colors = config.lib.stylix.colors;
      force_values = lib.mapAttrs (_: lib.mkForce);
      render_style = import ./render.nix { inherit config lib; };
      cross_icon = pkgs.writeText "vespers-cross.svg" (render_style (builtins.readFile ./vespers/cross.svg));
      date_status = pkgs.writeTextFile {
        name = "vespers-date";
        destination = "/bin/vespers-date";
        executable = true;
        checkPhase = "${pkgs.fish}/bin/fish --no-config --no-execute $out/bin/vespers-date";
        text = ''
          #!${pkgs.fish}/bin/fish --no-config
          set month_names Ianuarii Februarii Martii Aprilis Maii Iunii Iulii Augusti Septembris Octobris Novembris Decembris
          set date_parts (${pkgs.coreutils}/bin/date '+%-d %-m %Y' | string split ' ')
          set month_index $date_parts[2]
          printf '%s %s %s\n' $date_parts[1] $month_names[$month_index] $date_parts[3]
        '';
      };
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
      xdg.configFile."gtk-4.0/gtk.css".source = lib.mkForce (pkgs.concatText "vespers-gtk4.css" [
        config.xdg.configFile."gtk-3.0/gtk.css".source
        (pkgs.writeText "vespers-libadwaita.css" ''
          :root {
            --accent-color: #${colors.base0A};
            --accent-bg-color: #${colors.base0D};
            --accent-fg-color: #${colors.base00};
            --window-bg-color: #${colors.base00};
            --window-fg-color: #${colors.base05};
            --view-bg-color: #${colors.base00};
            --view-fg-color: #${colors.base05};
            --headerbar-bg-color: #${colors.base01};
            --headerbar-fg-color: #${colors.base05};
            --headerbar-backdrop-color: #${colors.base00};
            --sidebar-bg-color: #${colors.base01};
            --sidebar-fg-color: #${colors.base05};
            --sidebar-backdrop-color: #${colors.base00};
            --card-bg-color: #${colors.base01};
            --card-fg-color: #${colors.base05};
            --dialog-bg-color: #${colors.base01};
            --dialog-fg-color: #${colors.base05};
            --popover-bg-color: #${colors.base01};
            --popover-fg-color: #${colors.base05};
          }
        '')
      ]);
      qt.kvantum.themes = lib.mkForce [ flat_qt ];
      stylix.icons = {
        enable = true;
        package = pkgs.gruvbox-plus-icons.override { folder-color = "gold"; };
        dark = "Gruvbox-Plus-Dark";
        light = "Gruvbox-Plus-Light";
      };
      dconf.settings."org/gnome/desktop/interface".accent-color = "yellow";
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
          height = 48;
          spacing = 0;
          modules-left = lib.mkForce [ "custom/sigil" "ext/workspaces" ];
          modules-center = lib.mkForce [ "custom/date" "clock" ];
          modules-right = lib.mkForce [ "cpu" "memory" "network" "pulseaudio" "custom/language" "battery" "tray" "custom/power" ];
          "custom/sigil" = { format = "VESPERAE"; tooltip-format = "Ad maiorem Dei gloriam"; };
          "ext/workspaces".format-icons = lib.mkForce {
            "1" = "I"; "2" = "II"; "3" = "III"; "4" = "IV"; "5" = "V";
            "6" = "VI"; "7" = "VII"; "8" = "VIII"; "9" = "IX"; "10" = "X";
            urgent = "!";
          };
          clock = { format = lib.mkForce "{:%H:%M}"; };
          "custom/date" = {
            exec = "${date_status}/bin/vespers-date";
            interval = 60;
            tooltip = false;
          };
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
      programs.emacs.extraConfig = lib.mkAfter (render_style (builtins.readFile ./vespers/emacs.el));
      programs.fish.interactiveShellInit = lib.mkAfter (render_style (builtins.readFile ./vespers/prompt.fish));
      stylix.targets.fish.enable = true;
      stylix.targets.gtk.extraCss = ''
        * { border-radius: 0; box-shadow: none; text-shadow: none; transition: none; animation: none; }
        window decoration { border: 2px solid #${colors.base0D}; }
        button, entry, spinbutton, combobox, menu, popover, tooltip, headerbar, notebook > header, trough, progress, slider {
          background-image: none;
        }
        button { background-color: #${colors.base01}; border: 2px solid transparent; }
        button.image-button, button.flat, windowcontrols button { background-color: transparent; }
        button:hover { background-color: #${colors.base02}; border-color: transparent; }
        button:active, button:checked { background-color: #${colors.base0A}; color: #${colors.base00}; border-color: transparent; }
        entry { border: 2px solid #${colors.base03}; }
        entry:focus { border-color: #${colors.base0D}; }
        selection { background-color: #${colors.base0A}; color: #${colors.base00}; }
      '';
      home.file.".config/sys64/power/style.css".source = pkgs.writeText "vespers-power.css" (render_style (builtins.readFile ./vespers/power.css));
    };
  };
}
