{
  description = "Mirzas Nix Config";

  # nixConfig = {
  #   extra-substituters = ["https://arunoruto.cachix.org"];
  #   extra-trusted-public-keys = ["arunoruto.cachix.org-1:GQVw1YDtjt0+ElmQifxEI52a0pRVe9/gdcNEr8v8G14="];
  # };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # NixOS
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur.url = "github:nix-community/NUR";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    # nixvim-flake.url = "github:arunoruto/nvim.nix";
    # Styling
    stylix = {
      # url = "github:danth/stylix";
      url = "github:danth/stylix/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ags.url = "github:Aylur/ags";
    # poetry2nix = {
    #   url = "github:nix-community/poetry2nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
        ];
      };

      # Some customization
      # scheme = "catppuccin-macchiato";
      # scheme = "tokyo-night-dark";
      scheme = "gruvbox-material-dark-hard";
      # image = "anime/jjk/satoru-gojo-jujutsu-kaisen-5k-ac.jpg";
      # image = "anime/gruvbox/skull2.png";
      image = "anime/gruvbox/boonies.png";

      hostname-users = {
        # Personal
        "isshin" = "mirza"; # Framework Laptop AMD 7040
        "zangetsu" = "mirza"; # Framework Case Intel 11th
        "yhwach" = "mirza"; # Tower PC
        "kuchiki" = "mirza"; # New NAS Server
        "yoruichi" = "mirza"; # Crappy AMD Mini PC
        "kenpachi" = "mirza"; # S740 Mini PC
        "narouter" = "mirza"; # Firewall
        "aizen" = "mirza";
        # Work
        "kyuubi" = "mar"; # Crappy Work PC
        "madara" = "mar"; # Nice Work PC
      };
    in
    {
      nixosConfigurations = lib.genAttrs (builtins.attrNames hostname-users) (
        hostname:
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            username = hostname-users."${hostname}";
          };
          modules = [
            # inputs.nur.nixosModules.nur
            inputs.nixos-facter-modules.nixosModules.facter
            {
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVG8SSbWy37rel+Yhz9rjpNscmO1+Br57beNzWRdaQk"
              ];
              networking.hostName = lib.mkForce hostname;
              facter.reportPath = lib.mkIf (lib.pathExists ./hosts/${hostname}/facter.json) ./hosts/${hostname}/facter.json;
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  self.overlays.additions
                  self.overlays.unstable-packages
                ];
              };
              theming = {
                inherit scheme;
                inherit image;
              };
            }
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            ./homes
          ];
        }
      );

      homeConfigurations = lib.genAttrs (lib.lists.unique (builtins.attrValues hostname-users)) (
        user:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            # inputs.nur.hmModules.nur
            # ./modules/home-manager/home.nix
            ./homes/${user}
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

      overlays = import ./overlays { inherit inputs; };
      devShells.${system} = import ./shells pkgs lib;
      packages.${system} = import ./pkgs pkgs;
      # devShells.${system} = import ./shells nixpkgs.legacyPackages.${system};
      # packages.${system} = import ./pkgs nixpkgs.legacyPackages.${system};
    };
}
