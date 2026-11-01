{ config, lib, userName, ... }:
{
  config = lib.mkIf (config.style.name == "vespers-16") {
    stylix.base16Scheme = lib.mkForce {
      scheme = "Vespers XVI";
      author = "timeolord";
      base00 = "30221b";
      base01 = "3e2c21";
      base02 = "513b2c";
      base03 = "927553";
      base04 = "bca278";
      base05 = "e8dfce";
      base06 = "f2ebdd";
      base07 = "faf6ec";
      base08 = "bd5445";
      base09 = "ce8c42";
      base0A = "e2bd58";
      base0B = "91a35b";
      base0C = "72ada1";
      base0D = "bf9638";
      base0E = "a17cb0";
      base0F = "99613c";
    };
    home-manager.users.${userName} = { config, ... }: {
      stylix.targets.gtk.extraCss = lib.mkAfter ''
        @define-color headerbar_border_color #${config.lib.stylix.colors.base02};
        @define-color headerbar_shade_color transparent;
        @define-color headerbar_darker_shade_color transparent;
        @define-color sidebar_shade_color transparent;
        @define-color secondary_sidebar_shade_color transparent;
        @define-color card_shade_color transparent;
        @define-color popover_shade_color transparent;
        @define-color shade_color transparent;
        *:disabled { opacity: 1; color: #${config.lib.stylix.colors.base03}; }
      '';
    };
  };
}
