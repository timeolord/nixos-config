{ config, lib }:
text:
let
  names = map (index: "base0${lib.toHexString index}") (lib.range 0 15);
  values = map (name: config.lib.stylix.colors.${name}) names;
in
builtins.replaceStrings
  ((map (name: "@${name}@") names) ++ [ "@monospace_font@" "@desktop_size@" "@desktop_opacity@" ])
  (values ++ [ config.stylix.fonts.monospace.name (toString (config.stylix.fonts.sizes.desktop * 4 / 3)) (toString config.stylix.opacity.desktop) ])
  text
