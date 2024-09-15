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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # nixvim = {
    #   # url = "github:nix-community/nixvim";
    #   # inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   url = "github:nix-community/nixvim/nixos-24.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    # nil.url = "github:oxalica/nil";
    nixvim-flake.url = "github:arunoruto/nvim.nix";
    # Styling
    stylix = {
      # url = "github:danth/stylix";
      url = "github:danth/stylix/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private
    secrets = {
      # url = "git+ssh://git@github.com/arunoruto/secrets.nix.git?ref=main&shallow=1";
      url = "git+https://github.com/arunoruto/secrets.nix.git?ref=main&shallow=1";
      flake = false;
    };
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
    # theme = "tokyo-night-dark";
    theme = "gruvbox-material-dark-hard";
    # image = "anime/jjk/satoru-gojo-jujutsu-kaisen-5k-ac.jpg";
    # image = "anime/gruvbox/skull2.png";
    image = "anime/gruvbox/boonies.png";
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
          (final: prev: {
            neovim = inputs.nixvim-flake.packages.${system}.default;
          })
        ];
      };
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        overlay-unstable
        (final: prev: {
          neovim = inputs.nixvim-flake.packages.${system}.default;
        })
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
      nur.nixosModules.nur
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
      inputs.stylix.homeManagerModules.stylix
      stylix-config
      # {
      #   stylix.image = nixpkgs.lib.mkDefault ./home-manager/desktop/default-wallpaper.png;
      #   #stylix.targets.nixvim.enable = nixpkgs.lib.mkDefault false;
      # }
      ./modules/home-manager/home.nix
    ];
  in {
    nixosConfigurations = {
      # Framework Laptop AMD 7040
      isshin = nixpkgs.lib.nixosSystem {
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
            ./hosts/isshin
            home-manager.nixosModules.home-manager
            ./homes
          ];
      };
    
      # Framework Laptop Intel 11th
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
            ./hosts/zangetsu
            home-manager.nixosModules.home-manager
            ./homes
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
            ./hosts/kyuubi
            home-manager.nixosModules.home-manager
            ./homes
            # ./nixos/hosts/kyuubi/configuration.nix
            # home-manager.nixosModules.home-manager
          ];
      };

      # Server
      kuchiki = nixpkgs.lib.nixosSystem {
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
            ./hosts/kuchiki
          ];
      };

      # Firewall
      narouter = nixpkgs.lib.nixosSystem {
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
            ./hosts/narouter
            home-manager.nixosModules.home-manager
            ./homes
          ];
      };
    };

    homeConfigurations = {
      # mirza = home-manager.lib.homeManagerConfiguration {
      #   inherit pkgs;

      #   # Specify your home configuration modules here, for example,
      #   # the path to your home.nix.
      #   modules =
      #     home-manager-modules
      #     ++ [
      #       ./nixos/hosts/zangetsu/home.nix
      #     ];

      #   # Optionally use extraSpecialArgs
      #   # to pass through arguments to home.nix
      #   extraSpecialArgs = {
      #     inherit inputs;
      #     inherit theme;
      #     inherit image;
      #     user = "mirza";
      #   };
      # };

      mar = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          home-manager-modules
          ++ [
            {
              pc.enable = false;
            }
          ];
        extraSpecialArgs = {
          inherit inputs;
          inherit theme;
          inherit image;
          user = "mar";
        };
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        cmake
        glib
        stdenv.cc.cc.lib
        zlib
      ];

      shellHook = ''
        # export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [pkgs.glib pkgs.stdenv.cc.cc.lib pkgs.zlib]}:''$LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [pkgs.glib pkgs.stdenv.cc.cc.lib pkgs.zlib]}
        # https://github.com/python-poetry/poetry/issues/8623#issuecomment-1793624371
        export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
        echo "Flake Env"
      '';
    };
  };
}
