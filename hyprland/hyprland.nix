{
  config,
  pkgs,
  inputs,
  userName,
  ...
}:
let
  dmcfg = config.services.displayManager;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.users."${userName}" = (import ./hyprland-home.nix);
    }
  ];

  services.xserver.enable = false;
  services.displayManager.ly = {
    enable = true;
    settings = {
      shutdown_cmd = "/run/current-system/systemd/bin/systemctl poweroff";
      restart_cmd = "/run/current-system/systemd/bin/systemctl reboot";
      service_name = "ly";
      path = "/run/current-system/sw/bin";
      term_reset_cmd = "${pkgs.ncurses}/bin/tput reset";
      term_restore_cursor_cmd = "${pkgs.ncurses}/bin/tput cnorm";
      waylandsessions = "${dmcfg.sessionData.desktops}/share/wayland-sessions";
      xsessions = "${dmcfg.sessionData.desktops}/share/xsessions";
      xauth_cmd = "$PREFIX_DIRECTORY/bin/xauth";
      x_cmd = "$PREFIX_DIRECTORY/bin/X";
      setup_cmd = "${dmcfg.sessionData.wrapper}";
      
      allow_empty_password = true;
      animation = "none";
      animation_timeout_sec = 0;
      asterisk = "*";
      auth_fails = 10;
      battery_id = "null";
      auto_login_service = "ly-autologin";
      auto_login_session = "null";
      auto_login_user = "null";

      bg = "0x00000000";

      bigclock = "none";

      bigclock_12hr = false;

      bigclock_seconds = false;

      blank_box = true;

      border_fg = "0x00FFFFFF";

      box_title = "null";

      brightness_down_cmd = "$PREFIX_DIRECTORY/bin/brightnessctl -q -n s 10%-";

      brightness_down_key = "F5";

      brightness_up_cmd = "$PREFIX_DIRECTORY/bin/brightnessctl -q -n s +10%";

      brightness_up_key = "F6";

      clear_password = false;

      clock = "null";

      cmatrix_fg = "0x0000FF00";

      cmatrix_head_col = "0x01FFFFFF";

      cmatrix_min_codepoint = "0x21";

      cmatrix_max_codepoint = "0x7B";

      colormix_col1 = "0x00FF0000";

      colormix_col2 = "0x000000FF";

      colormix_col3 = "0x20000000";

      custom_sessions = "$CONFIG_DIRECTORY/ly/custom-sessions";

      default_input = "login";

      doom_fire_height = 6;
      
      doom_fire_spread = 2;

      doom_top_color = "0x009F2707";

      doom_middle_color = "0x00C78F17";

      doom_bottom_color = "0x00FFFFFF";

      edge_margin = 0;

      error_bg = "0x00000000";

      error_fg = "0x01FF0000";

      fg = "0x00FFFFFF";

      full_color = true;

      gameoflife_entropy_interval = 10;

      gameoflife_fg = "0x0000FF00";

      gameoflife_frame_delay = 6;

      gameoflife_initial_density = "0.4";

      hide_borders = false;

      hide_key_hints = false;

      hide_version_string = false;

      initial_info_text = "null";

      input_len = 34;

      lang = "en";

      login_cmd = "null";

      login_defs_path = "/etc/login.defs";

      logout_cmd = "null";

      ly_log = "/var/log/ly.log";

      margin_box_h = 2;

      margin_box_v = 1;

      min_refresh_delta = 5;

      numlock = false;

      restart_key = "F2";

      save = true;

      session_log = ".local/state/ly-session.log";

      shutdown_key = "F1";

      sleep_cmd = "null";

      sleep_key = "F3";

      text_in_center = true;

      vi_default_mode = "normal";

      vi_mode = false;

      xinitrc = "~/.xinitrc";

      # bigclock = "en";
      # bigclock_12hr = "true";

      # animation = "gameoflife";
      # gameoflife_entropy_interval = 10;
      # gameoflife_fg = "0x0000FF00";
      # gameoflife_frame_delay = 6;
      # gameoflife_initial_density = "0.4";

      # text_in_center = true;
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
