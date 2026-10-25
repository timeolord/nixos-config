{ config, pkgs, ... }:
{
  home.packages = [ pkgs.kitty ];
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      enable_audio_bell = "no";
    };
  };
}
