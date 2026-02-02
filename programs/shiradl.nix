{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  home.file.".shiradl/config.json".source = ./shiradl.json;
  home.packages = with pkgs; [
    shira
  ];
}
