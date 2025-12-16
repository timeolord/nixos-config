{
  config,
  pkgs,
  inputs,
  userName,
  ...
}:
{
  # nixpkgs.overlays = flake-overlays;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = userName; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openconnect
    ];
    ensureProfiles = {
      profiles.mcgill = {
        connection = {
          id = "McGill VPN";
          type = "vpn";
        };
        vpn = rec {
          # set these to your params
          gateway = "securevpn.mcgill.ca";
          remote = gateway;
          username = "melody.wei@mail.mcgill.ca";
          service-type = "org.freedesktop.NetworkManager.openconnect";
          protocol = "anyconnect";
          useragent = "AnyConnect";
          authtype = "password";
        };
      };
    };
  };
  
  
  # networking.wireless.userControlled.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    auto-optimise-store = true;
  };
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  i18n.extraLocales = [ "fr_CA.UTF-8/UTF-8" ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_CA.UTF-8";
    LC_IDENTIFICATION = "en_CA.UTF-8";
    LC_MEASUREMENT = "en_CA.UTF-8";
    LC_MONETARY = "en_CA.UTF-8";
    LC_NAME = "en_CA.UTF-8";
    LC_NUMERIC = "en_CA.UTF-8";
    LC_PAPER = "en_CA.UTF-8";
    LC_TELEPHONE = "en_CA.UTF-8";
    LC_TIME = "en_CA.UTF-8";
  };

  # Enables Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Configures the udev rules for bazecor
  services.udev.extraRules = builtins.readFile ./bazecor-rules;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Bluetooth stuff
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };
  services.blueman.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userName} = {
    isNormalUser = true;
    description = "Melody";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
  };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      core.editor = "emacs";
      user.name = "timeolord";
      user.email = "timeolord6677@gmail.com";
      safe.directory = [
        "/etc/nixos"
      ];
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      DefaultDownloadDirectory = "\${home}/downloads";
      DownloadDirectory = "\${home}/downloads";
      AutofillAdressEnabled = false;
      AutofillCreditCardEnabled = false;
      PasswordManagerEnabled = false;
      GenerativeAI = {
        Enabled = false;
        Locked = true;
      };
      Homepage = {
        StartPage = "previous-session";
      };
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      PictureInPicture = false;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gzip
    git

    (pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-unstable-pgtk;
      config = ./programs/emacs.el;
      defaultInitFile = true;
      alwaysEnsure = true;
    })
    emacs-lsp-booster
    nixfmt
    nil
    aspell
    aspellDicts.fr
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers
    aspellDicts.tr

    # trashy
    ntfs3g
  ];

  fonts.packages =
    with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      udev-gothic-nf
      meslo-lgs-nf
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise = {
    automatic = true;
    dates = "weekly";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
