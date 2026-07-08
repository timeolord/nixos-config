{ config, lib, pkgs, ... }:
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

  # aw-sync exports every bucket to a plain directory every 5 minutes, each
  # machine only writes its own subfolder so git-sync can push it conflict free
  systemd.user.services.aw-sync = {
    Unit = {
      Description = "sync activitywatch data to the git synced folder";
      After = [ "activitywatch.service" ];
      BindsTo = [ "activitywatch.target" ];
    };
    Service = {
      # git-sync clones the repo when it is missing, so wait for that instead
      # of creating a plain folder that would block the clone
      ExecStartPre = "${pkgs.coreutils}/bin/test -d ${config.home.homeDirectory}/activity-data/.git";
      ExecStart = "${pkgs.aw-server-rust}/bin/aw-sync --sync-dir ${config.home.homeDirectory}/activity-data daemon";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "activitywatch.target" ];
  };

  # the home manager module hooks the target to default.target, which fires at
  # login before hyprland is up, so awatcher finds no wayland session and exits
  # cleanly without ever being restarted. tie it to the graphical session instead
  systemd.user.targets.activitywatch = {
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
  };

  # belt and suspenders in case awatcher still comes up before the compositor
  systemd.user.services.activitywatch-watcher-awatcher.Service = {
    Restart = "always";
    RestartSec = 5;
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
