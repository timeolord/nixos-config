{
  config,
  pkgs,
  ...
}:
let
  logFolder = "${config.xdg.dataHome}/mpv-history";
  awWatcherMpvLogger = pkgs.stdenvNoCC.mkDerivation {
    pname = "aw-watcher-mpv-logger";
    version = "0-unstable-2024-05-05";
    src = pkgs.fetchFromGitHub {
      owner = "RundownRhino";
      repo = "aw-watcher-mpv-logger";
      rev = "a43bb05e34d2d245d48451604bf056c2fcc5e660";
      hash = "sha256-9MJ58nMP8WHce8WiJi173qe54h6FrQIzubptl9NcatE=";
    };
    # upstream bug, get_log ignores the log_folder_path option and uses a path
    # relative to the script, which would be the read only nix store here,
    # so we just patch the default to a writable location
    postPatch = ''
      substituteInPlace main.lua \
        --replace-fail "parent_dir(parent_dir(script_folder)) .. '/' .. 'mpv-history'" "'${logFolder}'"
    '';
    installPhase = ''
      mkdir -p $out/share/mpv/scripts/aw-watcher-mpv-logger
      cp main.lua $out/share/mpv/scripts/aw-watcher-mpv-logger/
    '';
    passthru.scriptName = "aw-watcher-mpv-logger";
  };
  awWatcherMpvSender = pkgs.python3Packages.buildPythonApplication {
    pname = "aw-watcher-mpv-sender";
    version = "0.2.2.1";
    pyproject = true;
    src = pkgs.fetchFromGitHub {
      owner = "RundownRhino";
      repo = "aw-watcher-mpv-sender";
      rev = "dee283787efcd4ae2db0c1fb6166d32e6b7a0e50";
      hash = "sha256-GeOeVDJIBnjccr1zNEoC4SHnopqdnfrzI85Zbj+71mQ=";
    };
    # the <3.11 pin only exists for pyinstaller which we dont use
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail '">=3.9,<3.11"' '">=3.9"'
    '';
    build-system = [ pkgs.python3Packages.poetry-core ];
    dependencies = with pkgs.python3Packages; [
      aw-client
      aw-core
    ];
    # upstream only supports python -m, so make a real executable for systemd
    postInstall = ''
      mkdir -p $out/bin
      cat > $out/bin/aw-watcher-mpv-sender <<EOF
      #!${pkgs.python3.interpreter}
      from aw_watcher_mpv_sender.main import main
      main()
      EOF
      chmod +x $out/bin/aw-watcher-mpv-sender
    '';
  };
in
{
  programs.mpv = {
    enable = true;
    scripts = [ awWatcherMpvLogger ];
  };
  # the lua script cant create the log folder itself
  xdg.dataFile."mpv-history/.keep".text = "";
  services.activitywatch.watchers.aw-watcher-mpv = {
    package = awWatcherMpvSender;
    executable = "aw-watcher-mpv-sender";
    settings.log_folder = logFolder;
  };
}
