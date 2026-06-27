{
  config,
  pkgs,
  userName,
  ...
}:
{
  home.packages = with pkgs; [
    anki
  ];
}
