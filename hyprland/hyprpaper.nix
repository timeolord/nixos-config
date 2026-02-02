{ config, pkgs, ... }:
{
  home.packages = [ pkgs.hyprpaper ];
  home.file.".wallpapers".source = ../wallpapers;
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      wallpaper = {
        monitor = " ";
        path = "~/.wallpapers/ivan_the_terrible.jpg";
        fit_mode = "cover";
      };
    };
  };
}
