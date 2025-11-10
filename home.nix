{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];
  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  home.packages = with pkgs; [
    bitwarden-desktop
    youtube-music
    discord
    signal-desktop
    bazecor
    obsidian
    todoist-electron
    qbittorrent
    zotero
    fastfetch
    any-nix-shell
    texliveFull
  ];

  home.file = {
    ".config/YouTube Music/config.json".source = ./programs/youtube-music.json;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    nix-direnv.enable = true;
  };
  programs.direnv-instant.enable = true;

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
