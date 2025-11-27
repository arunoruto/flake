{
  description = "Mirzas Nix Config";

  inputs = {
    # Stable
    # nixpkgs.url = "github:nixos/nixpkgs/refs/tags/25.11-beta";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

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
    # nix-ld = {
    #   url = "github:nix-community/nix-ld";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DEs
    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     home-manager.follows = "home-manager";
    #   };
    # };

    # helix.url = "github:helix-editor/helix";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      # url = "github:youwen5/zen-browser-flake";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim-flake.url = "github:arunoruto/nvim.nix";

    # PRs
    # matlab-pr.url = "https://github.com/james-atkins/nixpkgs/tree/pr/matlab";

    # Private
    # secrets = {
    #   # url = "git+ssh://git@github.com/arunoruto/secrets.nix.git?ref=main&shallow=1";
    #   url = "git+https://github.com/arunoruto/secrets.nix.git?ref=main&shallow=1";
    #   flake = false;
    # };
    wallpapers = {
      url = "git+https://github.com/arunoruto/wallpapers.git?ref=main&shallow=1";
      flake = false;
    };
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
      image = "art/solar-system-minimal.jpg";

      # currently onlu x86 linux is used
      # will maybe change in the future!
      # -> look into flake parts/utils
      mkLib = nixpkgs: nixpkgs.lib.extend (final: prev: (import ./lib final));
      lib = mkLib nixpkgs;
      system = "x86_64-linux";
      pkgs-attrs = {
        overlays =
          (with self.overlays; [
            additions
            modifications
            unstable-packages
            kodi
          ])
          ++ (with inputs; [ nur.overlays.default ]);
        config = {
          allowUnfree = true;
          # nvidia.acceptLicense = true;
        };
      };
      pkgs = import nixpkgs ({ inherit system; } // pkgs-attrs);
    in
    {
      inherit lib pkgs;
      nixosModules.default = ./modules/nixos;
      homeModules.default = ./modules/home-manager/home.nix;

      nixosConfigurations = import ./systems {
        inherit
          inputs
          self
          lib
          pkgs-attrs
          scheme
          image
          ;
      };
      # (import ./systems {
      #   inherit
      #     inputs
      #     self
      #     lib
      #     pkgs-attrs
      #     scheme
      #     image
      #     ;
      # })
      # // {
      #   pi = nixpkgs.lib.nixosSystem {
      #     system = "aarch64-linux";
      #     specialArgs = { inherit inputs; };
      #     modules = [ ./systems/aarch64-linux/pi ];
      #   };
      # };

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
          conf = self.nixosConfigurations;
        in
        {
          meta = {
            description = "my personal machines";
            nixpkgs = pkgs;
            nodeSpecialArgs = builtins.mapAttrs (
              name: value: (value._module.specialArgs // { inherit lib; })
            ) conf;
          };
        }
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
      lib.systemConfig.eachSystem systems (
        system:
        let
          pkgs-system = import inputs.nixpkgs-unstable {
            inherit system;
            config = {
              allowUnfree = true;
              # nvidia.acceptLicense = true;
            };
          };
        in
        {
          devShells = import ./shells pkgs-system lib;
          legacyPackages = import ./packages pkgs-system;
          # packages =
          #   lib.attrsets.removeAttrs
          #     (pkgs-system.lib.packagesFromDirectoryRecursive {
          #       inherit (pkgs-system) callPackage newScope;
          #       directory = ./packages/top-level;
          #     })
          #     [
          #       "callPackage"
          #       "newScope"
          #       "overrideScope"
          #       "packages"
          #       "recurseForDerivations"
          #     ];
          formatter = pkgs-system.nixfmt-tree;
          checks = {
            pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixfmt-rfc-style.enable = true;
              };
            };
          };
        }
      )
    );

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
      # "https://install.determinate.systems"
      # "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      # "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      # "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };
}
