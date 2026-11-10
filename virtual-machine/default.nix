{ config, lib, pkgs, userName, utils, ... }:
let
  desktop_command = "/run/current-system/sw/bin/start-hyprland --path /run/wrappers/bin/Hyprland";
in
{
  imports = lib.optional (builtins.pathExists ./access.nix) ./access.nix;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = { enable = true; device = "/dev/vda"; };
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
  zramSwap = { enable = true; memoryPercent = 40; };
  nix.settings = { max-jobs = 1; cores = 4; };
  services.btrfs.autoScrub.enable = lib.mkForce false;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # the host has no copy of the age identity and the vm uses its own login
  sops.secrets = lib.mkForce { };
  users.mutableUsers = lib.mkForce true;
  users.users.${userName} = {
    hashedPasswordFile = lib.mkForce null;
    initialHashedPassword = lib.mkForce null;
    hashedPassword = lib.mkForce "";
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;
  security.pam.services.login.allowNullPassword = true;
  security.pam.services.greetd.allowNullPassword = true;
  programs.fish.enable = true;

  # start the existing desktop directly when the virtual machine boots
  services.displayManager.ly.enable = lib.mkForce false;
  services.greetd = {
    enable = true;
    settings = {
      initial_session = { command = desktop_command; user = userName; };
      default_session = { command = "${pkgs.greetd}/bin/agreety --cmd ${lib.escapeShellArg desktop_command}"; user = "greeter"; };
    };
  };
  systemd.services.greetd = {
    after = [ "home-manager-${utils.escapeSystemdPath userName}.service" ];
    wants = [ "home-manager-${utils.escapeSystemdPath userName}.service" ];
  };
  system.activationScripts.nixosRepoAcl.deps = [ "users" ];

  home-manager.users.${userName} = { config, ... }: {
    options.home.packages = lib.mkOption {
      apply = packages: builtins.filter (package: lib.getName package != "audacity") packages;
    };
    config = {
      # double the original sixteen pixel grid instead of smoothing it at twenty eight
      programs.kitty.font.size = lib.mkForce 24;
      systemd.user.services.activitywatch-watcher-aw-watcher-steam.Unit.ConditionPathExists =
        "${config.xdg.configHome}/activitywatch/aw-watcher-steam/aw-watcher-steam.toml";
      systemd.user.services.aw-sync.Unit.ConditionPathExists = "${config.home.homeDirectory}/activity-data/.git";
      programs.fish.interactiveShellInit = lib.mkAfter ''
        function fish_greeting
          fastfetch
          echo "God Says..."
          godsays
        end
      '';
    };
  };
  system.activationScripts.vm_directories = lib.stringAfter [ "users" ] ''
    install -d -o ${userName} -g users /home/${userName}/{downloads,documents,projects,music,videos,notes}
    install -d -o ${userName} -g users /home/${userName}/emacs/{backups,autosaves}
  '';
  system.stateVersion = lib.mkForce "26.05";
}
