{
  config,
  pkgs,
  userName,
  ...
}:
{
  imports = [./nvidia.nix];

  # automatic btrfs snapshots via snapper
  # timeline takes a snapshot every minute, then cleanup thins them down.
  # snapshots are cow so a minute with no changes costs next to nothing.
  # retention: everything from the last hour is kept (min age 3600), then it
  # collapses to hourly for a day, then 7 daily (a week), then weekly. nix and
  # log live on separate subvolumes so they are never dragged into snapshots.
  services.snapper = {
    snapshotInterval = "minutely";
    cleanupInterval = "10m";
    persistentTimer = true;
    configs = let
      timeline = subvol: {
        SUBVOLUME = subvol;
        ALLOW_USERS = [userName];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = 3600;
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 0;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    in {
      root = timeline "/";
      home = timeline "/home";
    };
  };
}
