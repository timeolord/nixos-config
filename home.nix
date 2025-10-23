{ config, pkgs, ... }:

{
  home.username = "melk";
  home.homeDirectory = "/home/melk";


  
  # xsession.enable = true;
  # xsession.windowManager.command = "emacs";

  programs.kitty.enable = true; # required for the default Hyprland config
  #wayland.windowManager.hyprland.enable = true;
  #wayland.windowManager.hyprland.package = null;
  # home.file.".config/hypr/hyprland.conf" = {
  #   text = builtins.readFile ./hyprland.conf;
  #   onChange = ''
  #   cp /etc/nixos/hyprland.conf ~/.config/hypr/hyprland.conf
  #   '';
  #   force = true;
  # };
  # wayland.windowManager.hyprland.settings = {
  #  monitor = "dp1, 1920x1080@60.5, 0x0, 1";
  # };
  wayland.windowManager.hyprland.portalPackage = null;
  # wayland.windowManager.hyprland.systemd.variables = ["--all"];
  #  enable = true;
  #  xwayland.enable = true;
  #};

  # xdg.configFile."uwsm/env".soruce = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.packages = with pkgs; [
    bitwarden-desktop
    youtube-music
    discord
    signal-desktop
    bazecor
    zoom-us
    obsidian
    todoist-electron
  # bottles
    qbittorrent
    viennarna
    ghostscript
    pandoc
  ];
  
  # home.file."xinitrc".source = ./xinitrc;

  programs.git = {
    enable = true;
    userName = "melk";
    userEmail = "timeolord6677@gmail.com";
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      # epkgs.exwm
    ];
    extraConfig = builtins.readFile ./emacs.el;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
  };

  programs.fish = {
    enable = true;
  };

  home.shell = {
    enableFishIntegration = true;
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
