{ config, lib, pkgs, ... }:
let
  scripture = pkgs.writeTextFile {
    name = "waybar-scripture";
    destination = "/bin/waybar-scripture";
    executable = true;
    checkPhase = "${pkgs.fish}/bin/fish --no-config --no-execute $out/bin/waybar-scripture";
    text = "#!${pkgs.fish}/bin/fish --no-config\n" + builtins.replaceStrings
      [ "@godsays@" "@hyprctl@" "@jq@" "@date@" "@sleep@" "@timeout@" "@char_width@" ]
      [ "${pkgs.godsays}/bin/godsays" "${pkgs.hyprland}/bin/hyprctl" "${pkgs.jq}/bin/jq" "${pkgs.coreutils}/bin/date" "${pkgs.coreutils}/bin/sleep" "${pkgs.coreutils}/bin/timeout" (toString (config.stylix.fonts.sizes.desktop * 2.0 / 3.0)) ]
      (builtins.readFile ./scripture.fish);
  };
in
{
  programs.waybar.settings.scriptureBar = {
    name = "scripture";
    position = "top";
    layer = "top";
    height = 36;
    margin-top = 0;
    margin-bottom = 0;
    margin-left = 0;
    margin-right = 0;
    modules-center = [ "custom/godsays" ];
    "custom/godsays" = {
      exec = "${scripture}/bin/waybar-scripture";
      return-type = "json";
      restart-interval = 5;
      format = "{}";
      tooltip = true;
    };
  };
}
