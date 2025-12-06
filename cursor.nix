{
  config,
  pkgs,
  userName,
  ...
}:
{
  home.file.".local/share/icons/Sonic".source = ./cursors/Sonic;
  home.file.".local/share/icons/Sonic-xcursor".source = ./cursors/Sonic-xcursor;
}
