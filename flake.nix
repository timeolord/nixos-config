{
  description = "Flake(s) for all my computers";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    codex = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      rust_pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };
      haskell_pkgs = inputs.haskell-nix.legacyPackages.${system}.haskell-nix;
      overlays = [
        emacs-overlay.overlays.default
        godsays-flake.overlays.${system}.default
        (final: prev: {
          mozc = prev.mozc.overrideAttrs (old: {
            # qt expects the widget namespace without a leading scope
            postPatch = (old.postPatch or "") + ''
              substituteInPlace src/gui/dictionary_tool/dictionary_tool.ui \
                --replace-fail '::mozc::gui::DictionaryContentTableWidget' \
                  'mozc::gui::DictionaryContentTableWidget'
            '';
          });
          aw-qt = prev.aw-qt.overridePythonAttrs (_: {
            # the wrapper needs separate arguments instead of one string
            makeWrapperArgs = [ "--suffix" "PATH" ":" (final.lib.makeBinPath [ final.xdg-utils ]) ];
          });
          audacity = prev.audacity.overrideAttrs (old: {
            # keep muse types out of the generated qt qml sources
            postPatch = (old.postPatch or "") + ''
              substituteInPlace muse/framework/extensions/qml/Muse/Extensions/CMakeLists.txt \
                --replace-fail 'muse_create_qml_module(muse_extensions_qml ALIAS' \
                  'muse_create_qml_module(muse_extensions_qml NO_UNITY ALIAS'
            '';
          });
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python_final: python_prev: {
              # activitywatch still needs peewee 3
              aw-core = python_prev.aw-core.override {
                peewee = python_prev.peewee.overridePythonAttrs (_: {
                  version = "3.18.3";
                  src = final.fetchFromGitHub {
                    owner = "coleifer";
                    repo = "peewee";
                    tag = "3.18.3";
                    hash = "sha256-gMoU6YQMlEfL6onRAA/8v/08Je2jeLoZ3zw+2n1fmw4=";
                  };
                });
              };
            })
          ];
        })
      ];
      userNames = [
        "melktogo"
        "melk-pc"
        "melk-lab"
	"melkmobile"
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
      packages.x86_64-linux = isos // {
        rust-nightly = rust_pkgs.rust-bin.selectLatestNightlyWith (
          toolchain: toolchain.default.override { extensions = [ "rust-src" ]; }
        );
        zig-nightly = inputs.zig-overlay.packages.${system}.master;
        ghc-development = haskell_pkgs.compiler.${haskell_pkgs.resolve-compiler-name "ghc915"};
        codex-latest = inputs.codex.packages.${system}.default;
      };
      nixosConfigurations = configurations;
    };
}
