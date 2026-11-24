{
  config,
  pkgs,
  ...
}:
{
  imports = [./nvidia.nix];
  boot.extraModulePackages = [ config.boot.kernelPackages.yt6801 ];
  boot.kernelModules = [ "yt6801" ];
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
