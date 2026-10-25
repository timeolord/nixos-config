{ config, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  home.packages = [ pkgs.fuzzel ];
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "yes";
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        auto-select = "yes";
      };
      colors = {
        background = "${colors.base00}dd";
        text = "${colors.base05}ff";
        prompt = "${colors.base05}ff";
        placeholder = "${colors.base03}ff";
        input = "${colors.base05}ff";
        match = "${colors.base0A}80";
        selection = "${colors.base02}90";
        selection-text = "${colors.base08}ff";
        selection-match = "${colors.base0C}ff";
        counter = "${colors.base02}ff";
        border = "${colors.base01}ff";
      };
    };
  };
}
