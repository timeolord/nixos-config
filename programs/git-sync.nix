{ config, ... }:
{
  services.git-sync = {
    enable = true;
    repositories.notes = {
      path = "${config.home.homeDirectory}/notes";
      uri = "git@github.com:timeolord/notes.git";
    };
  };
}
