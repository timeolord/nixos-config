{ config, lib, pkgs, ... }:
let
  discord = pkgs.discord.override { withVencord = true; };
  theme_setup = pkgs.writeTextFile {
    name = "discord-theme-setup";
    destination = "/bin/discord-theme-setup";
    executable = true;
    checkPhase = "${pkgs.fish}/bin/fish --no-config --no-execute $out/bin/discord-theme-setup";
    text = "#!${pkgs.fish}/bin/fish --no-config\n" + builtins.replaceStrings
      [ "@jq@" "@coreutils@" ] [ "${pkgs.jq}/bin/jq" "${pkgs.coreutils}/bin" ]
      (builtins.readFile ./discord-theme.fish);
  };
  setup_command = "${theme_setup}/bin/discord-theme-setup ${lib.escapeShellArg "${config.xdg.configHome}/Vencord/settings/settings.json"} ${lib.boolToString config.stylix.targets.vencord.enable} || exit $?";
in {
  stylix.targets.vencord.extraCss = lib.mkBefore ''
    :root {
      --font: "${config.stylix.fonts.sansSerif.name}";
      --font-code: "${config.stylix.fonts.monospace.name}" !important;
    }
  '';
  home.packages = [ (pkgs.symlinkJoin {
    name = "discord-themed-${discord.version}";
    paths = [ discord ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/Discord" \
        --set VENCORD_USER_DATA_DIR ${lib.escapeShellArg "${config.xdg.configHome}/Vencord"} \
        --run ${lib.escapeShellArg setup_command}
      ln -sfn Discord "$out/bin/discord"
    '';
    meta = discord.meta;
  }) ];
}
