{
  config,
  pkgs,
  ...
}:
{
  imports = [./nvidia.nix];
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
