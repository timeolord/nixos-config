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

  environment.systemPackages = with pkgs; [
    brightnessctl # for ly
  ];
  
  services.xserver.enable = false;
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "colormix";
      session_log = "null";
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
