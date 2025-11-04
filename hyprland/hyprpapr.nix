{ config, pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "/etc/nixos/wallpapers/ivan_the_terrible.jpg"
      ];
      wallpaper = [
        ", /etc/nixos/wallpapers/ivan_the_terrible.jpg"
      ];
    };
  };
}
