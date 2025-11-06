{
  config,
  pkgs,
  inputs,
  userName,
  ...
}:
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
