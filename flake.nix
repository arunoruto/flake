{
  description = "Mirzas Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # NixOS
    nixos-hardware.url = "github:nixos/nixos-hardware";
    # Enable nur in the future
    nur.url = "github:nix-community/NUR";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    nur,
    home-manager,
    nixvim,
    stylix,
  }: let
    system = "x86_64-linux";
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.nvidia.acceptLicense = true;
      };
    };
    nixpkgs-config = {
      nixpkgs = {
        config.allowUnfree = true;
        overlays = [
          overlay-unstable
          nur.overlay
        ];
      };
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        overlay-unstable
        # make unstable packages available via overlay
        # (final: prev: {
        #   unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        # })
      ];
    };
    stylix-config = {
      stylix.image = nixpkgs.lib.mkDefault ./home-manager/desktop/default-wallpaper.png;
    };
  in {
    nixosConfigurations = {
      # Framework Laptop
      zangetsu = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          username = "mirza";
        };
        modules = [
          nixos-hardware.nixosModules.framework-11th-gen-intel
          stylix.nixosModules.stylix
          stylix-config
          nixpkgs-config
          ./nixos/hosts/zangetsu/configuration.nix
        ];
      };

      # Work PC
      kyuubi = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          username = "mar";
        };
        modules = [
          stylix.nixosModules.stylix
          nixpkgs-config
          ./nixos/hosts/kyuubi/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      mirza = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          nixvim.homeManagerModules.nixvim
          stylix.homeManagerModules.stylix
          {
            stylix.image = nixpkgs.lib.mkDefault ./home-manager/desktop/default-wallpaper.png;
            stylix.targets.nixvim.enable = nixpkgs.lib.mkDefault false;
          }
          ./home-manager/home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          user = "mirza";
        };
      };
      mar = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nixvim.homeManagerModules.nixvim
          stylix.homeManagerModules.stylix
          {
            stylix.image = nixpkgs.lib.mkDefault ./home-manager/desktop/default-wallpaper.png;
            stylix.targets.nixvim.enable = nixpkgs.lib.mkDefault false;
          }
          ./home-manager/home.nix
          ./nixos/hosts/kyuubi/home.nix
        ];
        extraSpecialArgs = {
          user = "mar";
        };
      };
    };
  };
}
