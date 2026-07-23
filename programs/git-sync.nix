{ config, lib, ... }:
let
  sync_repos = {
    notes = "git@github.com:timeolord/notes.git";
    language-learning = "git@github.com:timeolord/language-learning.git";
    activity-data = "git@github.com:timeolord/activity-data.git";
    website = "git@github.com:timeolord/timeolord.github.io.git";
  };
in
{
  services.git-sync = {
    enable = true;
    repositories = lib.mapAttrs (name: uri: {
      path = "${config.home.homeDirectory}/${name}";
      uri = uri;
    }) sync_repos;
  };

  # keep files over 50mb out of commits, github rejects them and git-sync retries forever
  # note this symlinks into .git, so clone the repo before the first rebuild on a fresh machine
  home.file = lib.mapAttrs' (name: _: {
    name = "${name}/.git/hooks/pre-commit";
    value = { source = ./git-sync/pre-commit; executable = true; };
  }) sync_repos;
}
