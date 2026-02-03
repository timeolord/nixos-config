{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  home.file.".shiradl/config.json".source = ./shiradl.json;
  home.file.".config/strawberry/strawberry.conf".source = ./strawberry.conf;
  home.packages = with pkgs; [
    strawberry
    shira
  ];
}
