{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./programs/fish/fish.nix
    ./programs/shiradl.nix
    ./programs/claude.nix
    ./programs/anki.nix
    ./programs/activitywatch.nix
    ./programs/mpv.nix
    ./programs/git-sync.nix
    ./programs/ssh/ssh.nix
    ./programs/aspell/aspell.nix
    ./programs/emacs.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  # without this file apps fall back to hardcoded capitalized dirs like
  # ~/Downloads, so point them at the lowercase ones instead
  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/music";
    videos = "${config.home.homeDirectory}/videos";
    documents = "${config.home.homeDirectory}/documents";
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "adwaita";
  };


  home.packages = with pkgs; [
    # bitwarden-desktop electron version is current eol
    # youtube-music is deprecated and is ai slop now...
    discord
    signal-desktop
    bazecor
    # obsidian, switched to org-roam
    # todoist-electron - broken 06/08/2026
    # for some reason qbittorent normal isn't working rn -06/03/2026
    qbittorrent-enhanced
    # zotero
    # for gog games
    heroic
    sgt-puzzles # for Theo
    godsays
    gimp-with-plugins
    unzip
    p7zip
    tree
    texliveFull
    audacity
    appimage-run
    vlc
    syspower
    gh
    jre
    dust
    nautilus
    # for editing the encrypted secrets
    sops
    age
    # for making gif demos of cli stuff
    vhs
    obs-studio
    ffmpeg
    # cabal-install
    # is this memes or maybe this will be good actually.
    # powershell
  ];

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
  home.stateVersion = "25.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
