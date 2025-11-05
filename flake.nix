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
        "melkPC"
        "melkLab"
      ];
      configurations = builtins.listToAttrs (map (username: {
        name = username;
        value = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs username; };
          modules = [
            import ./config.nix
          ];
        };
      }) userNames);
    in
    {
      nixpkgs.overlays = flake-overlays;
      nixosConfigurations = configurations;
    };
}
