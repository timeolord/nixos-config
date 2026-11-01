{ config, lib, pkgs, userName, ... }:
{
  config = lib.mkIf (config.style.name == "vespers") {
    home-manager.users.${userName} = { config, ... }:
    let
      colors = config.lib.stylix.colors;
      palette = map (index:
        let
          color = colors.${"base0${lib.toHexString index}"};
          channels = map (offset: "${toString (lib.fromHexString (builtins.substring offset 2 color))}.0") [ 0 2 4 ];
        in "vec3(${lib.concatStringsSep ", " channels}) / 255.0"
      ) (lib.range 0 15);
      render_shader = name: dither: pkgs.writeText name (builtins.replaceStrings
        [ "@palette@" "@dither@" ] [ (lib.concatStringsSep ",\n" palette) dither ] (builtins.readFile ./filter.frag));
      shader = render_shader "vespers-16.frag" "false";
      dither_shader = render_shader "vespers-16-dither.frag" "true";
      filter_toggle = pkgs.writeTextFile {
        name = "vespers-filter";
        destination = "/bin/vespers_filter";
        executable = true;
        checkPhase = "${pkgs.fish}/bin/fish --no-config --no-execute $out/bin/vespers_filter";
        text = "#!${pkgs.fish}/bin/fish --no-config\n" + builtins.replaceStrings
          [ "@hyprctl@" "@jq@" "@shader@" "@dither_shader@" ]
          [ "${pkgs.hyprland}/bin/hyprctl" "${pkgs.jq}/bin/jq" "${shader}" "${dither_shader}" ]
          (builtins.readFile ./filter.fish);
      };
    in {
      home.packages = [ filter_toggle ];
      xdg.configFile."hypr/vespers-16.frag".source = shader;
      xdg.configFile."hypr/vespers-16-dither.frag".source = dither_shader;
      wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
        hl.config({
          decoration = { screen_shader = "[[EMPTY]]" },
          debug = { damage_tracking = 1 },
        })
        hl.bind("SUPER + SHIFT + F12", hl.dsp.exec_cmd("${filter_toggle}/bin/vespers_filter toggle"))
      '';
    };
  };
}
