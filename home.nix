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
    ./programs/claude.nix
    ./programs/anki.nix
    ./programs/activitywatch.nix
    ./programs/mpv.nix
    ./programs/git-sync.nix
    ./programs/ssh/ssh.nix
    ./programs/aspell/aspell.nix
    ./programs/emacs.nix
    ./programs/strawberry/strawberry.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  # without this file apps fall back to hardcoded capitalized dirs like
  # ~/Downloads, so point them at the lowercase ones instead
  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    # also export XDG_DOWNLOAD_DIR and friends for apps that read the
    # environment instead of the user dirs file
    setSessionVariables = true;
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/music";
    videos = "${config.home.homeDirectory}/videos";
    documents = "${config.home.homeDirectory}/documents";
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    # kvantum is the only qt style engine with a catppuccin port
    style = {
      name = "kvantum";
      package = with pkgs; [
        libsForQt5.qtstyleplugin-kvantum
        qt6Packages.qtstyleplugin-kvantum
      ];
    };
  };
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-blue
  '';

  # nothing declared fonts for gtk before, so every gtk app picked its own
  # default out of the hundreds of installed nerd fonts
  gtk = {
    enable = true;
    font = {
      name = "UDEV Gothic NF";
      size = 11;
    };
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
      };
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    # the catppuccin package ships gtk4 css too, link it for gtk4 apps
    gtk4.theme = config.gtk.theme;
  };

  # pgtk apps like emacs read fonts from gsettings, not from settings.ini
  dconf.settings."org/gnome/desktop/interface" = {
    font-name = "UDEV Gothic NF 11";
    document-font-name = "UDEV Gothic NF 11";
    monospace-font-name = "UDEV Gothic NF 11";
    # libadwaita apps ignore gtk themes but do respect this
    color-scheme = "prefer-dark";
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
    # the kvantum color scheme for qt apps
    (catppuccin-kvantum.override {
      variant = "mocha";
      accent = "blue";
    })
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
