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
      xauth_cmd = "";
      x_cmd = "";
      setup_cmd = "${dmcfg.sessionData.wrapper}";
      # bigclock = "en";
      # bigclock_12hr = "true";

      animation = "gameoflife";
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
