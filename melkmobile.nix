{
  config,
  pkgs,
  ...
}:
{
  imports = [./nvidia.nix];
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
