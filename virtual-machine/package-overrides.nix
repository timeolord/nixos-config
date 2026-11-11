{ lib, userName, ... }:
{
  options.fonts.packages = lib.mkOption {
    apply = builtins.filter (package:
      let name = lib.getName package;
      in !lib.hasPrefix "nerd-fonts-" name || name == "nerd-fonts-symbols-only");
  };

  config.programs.steam.enable = lib.mkForce false;

  config.home-manager.users.${userName} = {
    disabledModules = [ ../programs/strawberry/strawberry.nix ];

    options.home.packages = lib.mkOption {
      apply = builtins.filter (package: !builtins.elem (lib.getName package) [
        "audacity"
        "gimp-with-plugins"
        "inkscape"
        "obs-studio"
        "texlive"
      ]);
    };
  };
}
