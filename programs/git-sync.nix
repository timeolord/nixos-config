{ config, ... }:
{
  services.git-sync = {
    enable = true;
    repositories = {
      notes = {
        path = "${config.home.homeDirectory}/notes";
        uri = "git@github.com:timeolord/notes.git";
      };
      language-learning = {
        path = "${config.home.homeDirectory}/language-learning";
        uri = "git@github.com:timeolord/language-learning.git";
      };
      activity-data = {
        path = "${config.home.homeDirectory}/activity-data";
        uri = "git@github.com:timeolord/activity-data.git";
      };
    };
  };
}
