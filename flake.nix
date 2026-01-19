{
  description = "Flake(s) for all my computers";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    godsays-flake = {
      url = "github:timeolord/godsays-haskell";
      # url = "path:/home/melk-pc/haskell/godsays";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      emacs-overlay,
      godsays-flake,
      nixos-generators,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        emacs-overlay.overlays.default
        godsays-flake.overlays.${system}.default
      ];
      userNames = [
        "melktogo"
        "melk-pc"
        "melk-lab"
      ];
      generateSystem =
        { userName, include-hardware }:
        let
          arguments = { inherit inputs userName; };
          user-module = ./${userName}.nix;
          hardware-module = ./hardware-configuration-${userName}.nix;
        in
        {
          inherit system;
          specialArgs = arguments;
          modules = [
            { nixpkgs = { inherit overlays; }; }
            ./config.nix
            ./hyprland/hyprland.nix
            user-module
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = arguments;
              home-manager.backupFileExtension = "backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${userName} = (import ./home.nix);
            }
            sops-nix.nixosModules.sops
          ]
          ++ (if include-hardware then [ hardware-module ] else [ ]);
        };
      configurations = builtins.listToAttrs (
        map (userName: {
          name = userName;
          value = nixpkgs.lib.nixosSystem (generateSystem {
            inherit userName;
            include-hardware = true;
          });
        }) userNames
      );
      isos = builtins.listToAttrs (
        map (userName: {
          name = userName + "-iso";
          value = nixos-generators.nixosGenerate (
            (generateSystem {
              inherit userName;
              include-hardware = false;
            })
            // {
              format = "install-iso";
            }
          );
        }) userNames
      );
    in
    {
      packages.x86_64-linux = isos;
      nixosConfigurations = configurations;
    };
}
