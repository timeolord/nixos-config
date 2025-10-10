{ config, pkgs, ... }:

{
  home.username = "melk";
  home.homeDirectory = "/home/melk";
  
  xsession.enable = true;
  xsession.windowManager.command = "…";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    bitwarden-desktop
    youtube-music
    discord
    signal-desktop
    bazecor
    zoom-us
    obsidian
  ];
  
  programs.fish = {
    enable = true;
  };
  
  programs.bash = {
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "melk";
    userEmail = "timeolord6677@gmail.com";
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
    ];
    extraConfig = builtins.readFile ./emacs.el;
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
