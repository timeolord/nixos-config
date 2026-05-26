{
  config,
  pkgs,
  ...
}:
{
  imports = [./nvidia.nix];
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandleLidSwitchDocked = "ignore";
  };
}
