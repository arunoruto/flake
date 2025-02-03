{
  description = "Mirzas Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # NixOS
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena.url = "github:zhaofengli/colmena";
    deploy-rs.url = "github:serokell/deploy-rs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    ucodenix.url = "github:e-tho/ucodenix";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-ld = {
    #   url = "github:nix-community/nix-ld";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nur.url = "github:nix-community/NUR";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DEs
    # nixos-cosmic = {
    #   url = "github:lilyinstarlight/nixos-cosmic";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     home-manager.follows = "home-manager";
    #   };
    # };
    # helix.url = "github:helix-editor/helix";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim-flake.url = "github:arunoruto/nvim.nix";
    # Styling
    stylix = {
      # url = "github:danth/stylix";
      # inputs.nixpkgs.follows = "nixpkgs";
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ags.url = "github:Aylur/ags";

    # Private
    secrets = {
      # url = "git+ssh://git@github.com/arunoruto/secrets.nix.git?ref=main&shallow=1";
      url = "git+https://github.com/arunoruto/secrets.nix.git?ref=main&shallow=1";
      flake = false;
    };
    wallpapers = {
      url = "git+https://github.com/arunoruto/wallpapers.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      snowfall-lib,
      colmena,
      deploy-rs,
      ...
    }@inputs:
    let
      # currently onlu x86 linux is used
      # will maybe change in the future!
      # -> look into flake parts/utils
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.unstable-packages
          # inputs.hyprpanel.overlay
        ];
      };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlay # or deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };

      ## Some customization
      ## Schemes: https://tinted-theming.github.io/base16-gallery/
      # scheme = "catppuccin-macchiato";
      # scheme = "tokyo-city-terminal-dark";
      # scheme = "outrun-dark";
      # scheme = "pandora";
      # scheme = "heetch";
      scheme = "gruvbox-material-dark-hard";
      # scheme = "gruvbox-material-light-hard";
      # scheme = "rose-pine-dawn";
      # scheme = "rose-pine";
      # image = "anime/jjk/satoru-gojo-jujutsu-kaisen-5k-ac.jpg";
      # image = "anime/gruvbox/skull2.png";
      # image = "anime/gruvbox/boonies.png";
      # image = "anime/dan-da-dan/op/okarun1.png";
      # image = "anime/dan-da-dan/op/okarun2.png";
      image = "anime/dan-da-dan/op/okarun3-gruvbox.png";
      # image = "anime/dan-da-dan/op/okarun4.png";
      # image = "anime/dan-da-dan/op/okarun5.png";
      # image = "anime/dan-da-dan/op/jiji1.png";
      # image = "anime/dan-da-dan/op/turbogranny1.png";

      machines = {
        # Personal
        # Framework Laptop AMD 7040
        isshin.usernames = [ "mirza" ];
        # Framework Case Intel 11th
        zangetsu.usernames = [ "mirza" ];
        # Tower PC
        yhwach.usernames = [ "mirza" ];
        # New NAS Server
        # kuchiki.usernames = [ "mirza" ];
        # Crappy AMD Mini PC
        yoruichi.usernames = [ "mirza" ];
        # M720q Mini PC
        shinji.usernames = [ "mirza" ];
        # S740 Mini PC
        kenpachi.usernames = [ "mirza" ];
        # Firewall
        # narouter.usernames = [ "mirza" ];
        # Server
        # aizen.usernames = [ "mirza" ];

        # Work
        # Crappy Work PC
        kyuubi.usernames = [ "mar" ];
        # Nice Work PC
        madara.usernames = [ "mar" ];
      };

      unique-users = lib.lists.unique (
        lib.lists.concatMap (x: x.usernames) (builtins.attrValues machines)
      );
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        hostname: conf:
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            # TODO: enable support for multiple users in the future
            # Could be relevant for setting up a kodi or github-runner user
            username = lib.lists.elemAt conf.usernames 0;
            # username = machines."${hostname}";
          };
          modules = [
            self.nixosModules
            # inputs.nur.nixosModules.nur
            inputs.nixos-facter-modules.nixosModules.facter
            {
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVG8SSbWy37rel+Yhz9rjpNscmO1+Br57beNzWRdaQk"
              ];
              networking.hostName = lib.mkForce hostname;
              facter.reportPath = lib.mkIf (lib.pathExists ./systems/x86_64-linux/${hostname}/facter.json) ./systems/x86_64-linux/${hostname}/facter.json;
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  # self.overlays.additions
                  self.overlays.python
                  self.overlays.unstable-packages
                  # inputs.hyprpanel.overlay
                ];
              };
              theming = {
                inherit scheme;
                inherit image;
              };

            }
            (
              { lib, ... }:
              {
                options.username = lib.mkOption {
                  type = lib.types.str;
                  default = lib.lists.elemAt conf.usernames 0;
                };
              }
            )
            ./systems/x86_64-linux/${hostname}
            home-manager.nixosModules.home-manager
            ./homes/x86_64-linux
          ];
        }
      ) machines;

      # homeConfigurations = lib.genAttrs (lib.lists.unique (builtins.attrValues machines)) (
      homeConfigurations = lib.genAttrs unique-users (
        user:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            # self.homeManagerModules
            # inputs.nur.hmModules.nur
            # ./modules/home-manager/home.nix
            ./homes/x86_64-linux/${user}
            inputs.stylix.homeManagerModules.stylix
            {
              theming = {
                inherit scheme;
                inherit image;
              };
            }
          ];
          extraSpecialArgs = {
            inherit inputs;
            inherit user;
          };
        }
      );

      nixosModules.default = ./modules/nixos;
      homeManagerModules.default = ./modules/home;
      # overlays = import ./overlays/default-bak.nix { inherit inputs; };
      overlays = {
        # additions = import ./overlays/additions.nix { inherit inputs; };
        python = import ./overlays/python.nix { };
        unstable-packages = import ./overlays/unstable.nix { channels = inputs; };
      };
      devShells.${system} = import ./shells pkgs lib;
      # packages.${system} = import ./pkgs pkgs;

      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      colmena =
        let
          conf = self.nixosConfigurations;
        in
        {
          meta = {
            description = "my personal machines";
            nixpkgs = import nixpkgs {
              inherit system;
              # overlays = [ ];
            };
            # nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) conf;
            nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) conf;
          };
        }
        // builtins.mapAttrs (name: value: {
          imports = value._module.args.modules;
          inherit (conf.${name}.config.colmena) deployment;
        }) conf;

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      # deploy.nodes = builtins.mapAttrs (hostname: conf: {
      #   inherit hostname;
      #   profiles.system = {
      #     user = "root";
      #     path = deployPkgs.deploy-rs.lib.activate.nixos conf;
      #     remoteBuild = true;
      #   };
      # }) self.nixosConfigurations;
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
      # "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      # "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };
}
