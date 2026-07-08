{ pkgs, ... }:
{
  services.activitywatch = {
    enable = true;
    watchers = {
      # awatcher replaces both aw-watcher-window and aw-watcher-afk on wayland,
      # it talks to hyprland through the wlr foreign toplevel and ext idle protocols
      awatcher.package = pkgs.awatcher;
    };
  };
}
