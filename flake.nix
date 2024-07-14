{
  description = "Mirzas Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # NixOS
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Enable nur in the future
    nur.url = "github:nix-community/NUR";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # url = "github:nix-community/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil.url = "github:oxalica/nil";
    # Styling
    stylix = {
      url = "github:danth/stylix";
      # url = "github:danth/stylix/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
    # Misc
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    lanzaboote,
    nur,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    # theme = "catppuccin-macchiato";
    theme = "tokyo-night-dark";
    image = "anime/jjk/satoru-gojo-jujutsu-kaisen-5k-ac.jpg";
    # secure-boot = [
    #   lanzaboote.nixosModules.lanzaboote
    #   ({
    #     pkgs,
    #     lib,
    #     ...
    #   }: {
    #     environment.systemPackages = [pkgs.sbctl];
    #     boot = {
    #       loader.systemd-boot.enable = lib.mkForce false;
    #       lanzaboote = {
    #         enable = true;
    #         pkiBundle = "/etc/secureboot";
    #       };
    #     };
    #   })
    # ];
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
          # nur.overlay
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
      # theme = "tokyo-night-dark";
      # image = "anime/jjk/satoru-gojo-jujutsu-kaisen-5k-ac.jpg";
    };
    nixos-modules = [
      nixpkgs-config
      # nix-ld.nixosModules.nix-ld
      nur.nixosModules.nur
      # stylix.nixosModules.stylix
      stylix-config
    ];
    home-manager-modules = [
      # {
      #   nixpkgs.overlays = [
      #     neorg-overlay.overlays.default
      #   ];
      # }
      nur.hmModules.nur
      # nixvim.homeManagerModules.nixvim
      # stylix.homeManagerModules.stylix
      stylix-config
      # {
      #   stylix.image = nixpkgs.lib.mkDefault ./home-manager/desktop/default-wallpaper.png;
      #   #stylix.targets.nixvim.enable = nixpkgs.lib.mkDefault false;
      # }
      ./home-manager/home.nix
    ];
  in {
    nixosConfigurations = {
      # Framework Laptop
      zangetsu = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit theme;
          inherit image;
          username = "mirza";
        };
        modules =
          nixos-modules
          ++ [
            ./nixos/hosts/zangetsu/configuration.nix
          ];
      };

      # Work PC
      kyuubi = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit theme;
          inherit image;
          username = "mar";
        };
        modules =
          nixos-modules
          ++ [
            ./nixos/hosts/kyuubi/configuration.nix
          ];
      };
    };

    homeConfigurations = {
      mirza = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules =
          home-manager-modules
          ++ [
            ./nixos/hosts/zangetsu/home.nix
          ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit inputs;
          inherit theme;
          inherit image;
          user = "mirza";
        };
      };

      mar = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          home-manager-modules
          ++ [
            ./nixos/hosts/kyuubi/home.nix
          ];
        extraSpecialArgs = {
          inherit inputs;
          inherit theme;
          inherit image;
          user = "mar";
        };
      };
    };
  };
}
