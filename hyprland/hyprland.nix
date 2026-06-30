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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };

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
