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
      home-manager.users.${userName} = (import ./hyprland-home.nix);
    }
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl # for ly
  ];
  services.xserver.enable = false;
  services.blueman.enable = true;
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
