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
  services.displayManager.ly.enable = true;
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
