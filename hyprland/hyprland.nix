{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      background_opacity = 0.5;
      enable_audio_bell = "no";
    };
  };
}
