{
  description = "Mirzas Nix Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
    stylix = {
      # url = "github:nix-community/stylix";
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-update.url = "github:nix-community/nixpkgs-update";
    # NixOS
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    colmena.url = "github:zhaofengli/colmena";
    nixai = {
      url = "github:olafkfreund/nix-ai-help";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    cpu-microcodes = {
      # url = "github:platomav/CPUMicrocodes/ec5200961ecdf78cf00e55d73902683e835edefd";
      url = "github:platomav/CPUMicrocodes";
      flake = false;
    };
    ucodenix = {
      url = "github:e-tho/ucodenix";
      inputs.cpu-microcodes.follows = "cpu-microcodes";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    wallpapers = {
      url = "git+https://github.com/arunoruto/wallpapers.git?ref=main&shallow=1";
      flake = false;
    };
    stump-fork.url = "github:arunoruto/stump/metadata-manual-search";
  };

  outputs =
    {
      self,
      nixpkgs,
      colmena,
      ...
    }@inputs:
    let
      ## Some customization
      ## Schemes: https://tinted-theming.github.io/base16-gallery/
      # scheme = "catppuccin-macchiato";
      # scheme = "tokyo-city-terminal-dark";
      # scheme = "outrun-dark";
      # scheme = "pandora";
      # scheme = "heetch";
      # scheme = "solarized-dark";
      scheme = "gruvbox-material-dark-hard";
      # scheme = "gruvbox-material-light-hard";
      # scheme = "rose-pine-dawn";
      # scheme = "rose-pine";
      # image = "anime/jjk/satoru-gojo-jujutsu-kaisen-5k-ac.jpg";
      # image = "anime/gruvbox/skull2.png";
      # image = "anime/gruvbox/boonies.png";
      # image = "anime/dan-da-dan/op/okarun1.png";
      # image = "anime/dan-da-dan/op/okarun2.png";
      # image = "anime/dan-da-dan/op/okarun3-gruvbox.png";
      # image = "anime/dan-da-dan/op/okarun4.png";
      # image = "anime/dan-da-dan/op/okarun5.png";
      # image = "anime/dan-da-dan/op/jiji1.png";
      # image = "anime/dan-da-dan/op/turbogranny1.png";
      # image = "art/solar-system.jpg";
      # image = "art/gruvb_solarsys.png";
      # image = "art/solar-system-minimal.jpg";
      image = "sun/the-fall-of-icarus-fall-size-3840.png";

      mkLib = nixpkgs: nixpkgs.lib.extend (final: prev: (import ./lib final));
      lib = mkLib nixpkgs;
      pkgs-attrs = {
        overlays =
          (with self.overlays; [
            additions
            modifications
            unstable-packages
            python
            kodi
            home-assistant
            custom-packages
          ])
          ++ (with inputs; [ nur.overlays.default ]);
        config = {
          allowUnfree = true;
          # nvidia.acceptLicense = true;
        };
      };
      # Auto-discovered hosts: { nixos = {...}; darwin = {...}; isoConfigurations = {...}; }
      hosts = import ./systems {
        inherit
          inputs
          self
          lib
          pkgs-attrs
          scheme
          image
          ;
      };
    in
    {
      inherit lib;
      nixosModules.default = import ./modules/nixos;
      darwinModules.default = import ./modules/darwin;
      homeModules = {
        default = import ./modules/home-manager/default.nix;
        devix = import ./modules/devix/targets/home;
      };
      devenvModules = {
        default = import ./modules/devix;
        core = ./modules/devix/core;
        helix = import ./modules/devix/consumers/helix/devenv.nix;
        python = ./modules/devix/profiles/python.nix;
      };

      nixosConfigurations = hosts.nixos // hosts.isoConfigurations;

      darwinConfigurations = hosts.darwin;

      homeConfigurations = import ./homes {
        inherit
          inputs
          self
          lib
          pkgs-attrs
          scheme
          image
          ;
      };

      overlays = import ./overlays { inherit inputs; };

      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      colmena =
        let
          # Only real hosts, not the installer images (iso-* have no colmena
          # deployment options and would fail hive evaluation).
          conf = hosts.nixos;
          system = "x86_64-linux";
        in
        {
          meta = {
            description = "my personal machines";
            nixpkgs = import nixpkgs ({ inherit system; } // pkgs-attrs);
            nodeSpecialArgs = builtins.mapAttrs (
              name: value: (value._module.specialArgs // { inherit lib; })
            ) conf;
          };
        }
        # `_module.specialArgs` / `_module.args.modules` are module-system
        # internals; colmena needs the raw module list to build each node.
        // builtins.mapAttrs (name: value: {
          imports = value._module.args.modules;
          inherit (conf.${name}.config.colmena) deployment;
        }) conf;
    }
    // (
      let
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];
      in
      lib.eachSystem systems (
        system:
        let
          pkgs-system = import inputs.nixpkgs-unstable {
            inherit system;
            config = {
              allowUnfree = true;
              # nvidia.acceptLicense = true;
            };
          };
          # Hooks that gate what lands in git history: formatting, the
          # packages/**/package.nix convention, and keeping flake.lock
          # CI-only. These run in `nix flake check`, so they must stay green.
          ciHooks = {
            nixfmt.enable = true;
            # Newly added packages/**/package.nix must opt into
            # __structuredAttrs and strictDeps (see the script).
            new-package-attrs = {
              enable = true;
              name = "new packages set structuredAttrs/strictDeps";
              entry = "./scripts/check-new-packages.sh";
              files = "packages/.*/package\\.nix$";
            };
            # flake.lock is bumped only by the scheduled Update Lockfile
            # action (see .github/workflows/update.yaml); reject local commits.
            lockfile-managed-by-ci = {
              enable = true;
              name = "flake.lock is CI-managed";
              entry = "./scripts/block-lockfile-commit.sh";
              files = "^flake\\.lock$";
              pass_filenames = false;
            };
          };
          # statix/deadnix are lints, not correctness gates: enforced on
          # commit locally, but excluded from `checks` so a lint finding
          # never fails CI.
          lintHooks = {
            deadnix = {
              enable = true;
              settings = {
                noLambdaArg = true;
                noLambdaPatternNames = true;
              };
            };
            # statix reads statix.toml (ignores generated hardware-configuration.nix)
            statix.enable = true;
          };
          gitHooksLocal = inputs.git-hooks.lib.${system}.run {
            package = pkgs-system.prek;
            src = ./.;
            hooks = ciHooks // lintHooks;
          };
        in
        {
          devShells =
            (import ./shells {
              pkgs = pkgs-system;
              inherit lib self inputs;
            })
            // {
              nix = pkgs-system.mkShell {
                inherit (gitHooksLocal) shellHook;
                buildInputs =
                  (with pkgs-system; [
                    just
                    statix
                    deadnix
                    nixfmt-tree
                  ])
                  ++ gitHooksLocal.enabledPackages;
              };
            };
          legacyPackages = import ./packages pkgs-system;
          # ISO images are x86_64-linux only; expose their checksums as packages
          # so `nix build .#iso-<host>` works there.
          packages = lib.optionalAttrs (system == "x86_64-linux") (
            lib.mapAttrs (_: cfg: cfg.config.system.build.isoChecksums) hosts.isoConfigurations
          );
          formatter = pkgs-system.nixfmt-tree;
          checks = {
            pre-commit-check = inputs.git-hooks.lib.${system}.run {
              package = pkgs-system.prek;
              src = ./.;
              hooks = ciHooks;
            };
          };
        }
      )
    );

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://colmena.cachix.org"
      "https://install.determinate.systems"
      # "https://helix.cachix.org"
      "http://madara.king-little.ts.net:5000"
      "http://kuchiki.sparrow-yo.ts.net:5000"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      # "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "madara:ZyOQZ0jEn5G9qInb25sEz3LwRmJwBFkhji83xwyLWpk="
      "kuchiki:jrqnrTt/N/YbmQ13eU97X03e/HVCKso30z4Z/zBXGSo="
    ];
  };
}
