{ config, lib, pkgs, ... }:
let
  preflight = pkgs.writeText "rebuild-preflight.py" (builtins.readFile ./rebuild-preflight.py);
  rebuild = pkgs.writeTextFile {
    name = "rebuild-system";
    destination = "/bin/rebuild-system";
    executable = true;
    text = builtins.replaceStrings [ "#!/usr/bin/env fish" ] [ ''
      #!${pkgs.fish}/bin/fish
      set -gx REBUILD_PREFLIGHT ${lib.escapeShellArg (toString preflight)}
      set -gx REBUILD_SUBSTITUTERS ${lib.escapeShellArg (lib.concatStringsSep " " config.nix.settings.substituters)}
      set -gx REBUILD_TRUSTED_KEYS ${lib.escapeShellArg (lib.concatStringsSep " " config.nix.settings.trusted-public-keys)}
    '' ] (builtins.readFile ./rebuild.sh);
  };
in
{
  environment.systemPackages = [ rebuild ];
}
