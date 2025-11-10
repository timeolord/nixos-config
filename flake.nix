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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      rust-overlay,
      emacs-overlay,
      ...
    }:
    let
      flake-overlays = [
        rust-overlay.overlays.default
        emacs-overlay.overlays.default
      ];
      userNames = [
        "melktogo"
        "melk-pc"
        "melk-lab"
      ];
      configurations = builtins.listToAttrs (
        map (
          userName:
          let
            arguments = { inherit inputs userName flake-overlays; };
            user-module = (./. + builtins.toPath "/${userName}.nix");
            hardware-module = (./. + builtins.toPath "/hardware-configuration-${userName}.nix");
          in
          {
            name = userName;
            value = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = arguments;
              modules = [
                ./config.nix
                ./hyprland/hyprland.nix
                user-module
                hardware-module
                home-manager.nixosModules.home-manager
                {
                  home-manager.extraSpecialArgs = arguments;
                  home-manager.backupFileExtension = "backup";
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users."${userName}" = (import ./home.nix);
                }
              ];
            };
          }
        ) userNames
      );
    in
    {
      nixosConfigurations = configurations;
    };
}
