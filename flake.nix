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
        map (userName: {
          name = userName;
          value = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs userName flake-overlays; };
            modules = [
              (import ./config.nix)
              ./hyprland/hyprland.nix
              inputs.home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users."${userName}" = (import ./home.nix);
              }
              (./. + builtins.toPath "/${userName}.nix")
              (./. + builtins.toPath "/hardware-configuration-${userName}.nix")
            ];
          };
        }) userNames
      );
    in
    {
      nixosConfigurations = configurations;
    };
}
