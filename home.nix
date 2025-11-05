userName:{ config, pkgs, ... }:
{
  imports = [
    ./hyprland/hyprland.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  home.packages = with pkgs; [
    bitwarden-desktop
    youtube-music
    discord
    signal-desktop
    bazecor
    zoom-us
    obsidian
    todoist-electron
    qbittorrent
    ghostscript
    pandoc
    zotero
    fastfetch
    any-nix-shell
  ];

  # programs.emacs = {
  #   enable = true;
  #   extraConfig = builtins.readFile ./emacs.el;
  # };

  programs.bash = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set PATH /etc/nixos /home/${userName}/.local/bin $PATH
      abbr --add rb rebuild.sh
      set -g fish_greeting
    '';
    interactiveShellInit = ''
      fastfetch
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      godsays
    '';
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
