{ config, pkgs, ... }:
{
  home.packages = [ pkgs.fuzzel ];
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi_aware = "yes";
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        auto-select = "yes";
      };
      colors = {
        background = "282828dd";
        text = "f4d9e1ff";
        prompt = "f4d9e1ff";
        placeholder = "838ba7ff";
        input = "f4d9e1ff";
        match = "ffc40080";
        selection = "8c00ff90";
        selection-text = "ff3f7fff";
        selection-match = "ffce00ff";
        counter = "8c00ffff";
        border = "450693ff";
      };
    };
  };
}
