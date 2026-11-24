{ config, lib, pkgs, userName, ... }:
let
  render_style = import ../styles/render.nix { inherit config lib; };
  hyprland_base_config = render_style (builtins.readFile ./hyprland.lua);
  additional_config = builtins.readFile (./${userName}.lua);
  lock_enabled = userName != "melk-vm";
  inherit (config.lib.stylix) colors;
  loginctl = "${pkgs.systemd}/bin/loginctl";
  hyprland_config = hyprland_base_config + additional_config + lib.optionalString lock_enabled ''
    hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("${loginctl} lock-session"))
  '';
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

  services.hypridle = lib.mkIf lock_enabled {
    enable = true;
    settings.general = {
      lock_cmd = "${pkgs.procps}/bin/pidof hyprlock >/dev/null || ${pkgs.hyprlock}/bin/hyprlock --no-fade-in";
      before_sleep_cmd = "${loginctl} lock-session auto";
      after_sleep_cmd = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
      inhibit_sleep = 3;
    };
  };

  xdg.configFile."hypr/hyprlock.conf" = lib.mkIf lock_enabled {
    text = ''
      background {
        monitor =
        color = rgb(${colors.base00})
      }

      input-field {
        monitor =
        size = 360, 64
        rounding = 0
        outline_thickness = 4
        outer_color = rgb(${colors.base0D})
        inner_color = rgb(${colors.base01})
        font_color = rgb(${colors.base05})
        font_family = ${config.stylix.fonts.monospace.name}
        placeholder_text = Password
        fade_on_empty = false
      }
    '';
  };

  home.sessionVariables = {
    # GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  home.file.".config/sys64/power/config.conf".source = ./syspower.conf;
  home.file.".config/sys64/power/style.css".source = lib.mkDefault ./syspower.css;

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
