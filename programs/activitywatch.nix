{ config, pkgs, ... }:
let
  awWatcherSteam = pkgs.python3Packages.buildPythonApplication {
    pname = "aw-watcher-steam";
    version = "0.0.1";
    pyproject = true;
    src = pkgs.fetchFromGitHub {
      owner = "Edwardsoen";
      repo = "aw-watcher-steam";
      rev = "55ea988994acfbf729fa43612f2057a310c1cc8f";
      hash = "sha256-wd+q83MlgMeiYSHQwMtszwnDrkaDN3yVkV/P5HsU89U=";
    };
    build-system = [ pkgs.python3Packages.poetry-core ];
    dependencies = with pkgs.python3Packages; [
      requests
      aw-client
    ];
  };
in
{
  services.activitywatch = {
    enable = true;
    watchers = {
      # awatcher replaces both aw-watcher-window and aw-watcher-afk on wayland,
      # it talks to hyprland through the wlr foreign toplevel and ext idle protocols
      awatcher.package = pkgs.awatcher;
      # polls the steam web api for the currently played game
      aw-watcher-steam.package = awWatcherSteam;
    };
  };

  # the watcher config holds the steam api key, so the whole file lives
  # encrypted in the repo and gets decrypted here on activation
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    secrets."aw-watcher-steam.toml" = {
      format = "binary";
      sopsFile = ../secrets/aw-watcher-steam.toml;
      path = "${config.xdg.configHome}/activitywatch/aw-watcher-steam/aw-watcher-steam.toml";
    };
  };

  # without the decrypted config the watcher exits immediately, so wait for
  # sops and retry instead of staying dead
  systemd.user.services.activitywatch-watcher-aw-watcher-steam = {
    Unit.After = [ "sops-nix.service" ];
    Service = {
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
