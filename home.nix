{
  config,
  pkgs,
  userName,
  ...
}:
{
  imports = [
    ./programs/fish/fish.nix
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
    sgt-puzzles # for Theo
    godsays
    gimp-with-plugins
    unzip
    tree
    texliveFull
  ];

  #home.file = {
  #  ".config/YouTube Music/config.json".source = ./programs/youtube-music.json;
  #};

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
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
