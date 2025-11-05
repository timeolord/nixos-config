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
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      rust-overlay,
      ...
    }:
    let
      flake-overlays = [
        rust-overlay.overlays.default
      ];
      userName = "melktogo";  
    in
    {
      nixosConfigurations = {
        "${userName}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./configuration.nix flake-overlays userName)
            home-manager.nixosModules.home-manager
            {
              home-manager.users.melk = import ./home.nix ;
            }
          ];
        };
      };
    };
}
