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
            home-manager-module = inputs.home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${userName}" = (import ./home.nix);
            };
            user-module = (./. + builtins.toPath "/${userName}.nix");
            hardware-module = (./. + builtins.toPath "/hardware-configuration-${userName}.nix");
          in
          {
            name = userName;
            value = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inherit inputs userName flake-overlays; };
              modules = [
                ./config.nix
                ./hyprland/hyprland.nix
                home-manager-module
                user-module
                hardware-module
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
