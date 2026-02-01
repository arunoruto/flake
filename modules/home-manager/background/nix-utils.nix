{
  config,
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}@args:
let
  inherit (config) user;
  nix-repl = pkgs.writeScriptBin "nix-repl" (
    ''
      #!${lib.getExe pkgs.expect}

      spawn nix repl
      expect {
        "Welcome to Nix" {}
        -r "Nix (\\d+\\.\\d+\\.\\d+)" {}
      }
      send -- ":lf ${config.home.sessionVariables.NH_FLAKE}\r"
      expect -r "Added (\\d+) variables."
      send -- "hm = homeConfigurations.${config.home.username}\r"
      send -- "pkgs = hm.pkgs\r"
    ''
    + lib.optionalString (args ? nixosConfig) ''
      send -- "os = nixosConfigurations.${osConfig.networking.hostName}\r"
    ''
    + ''
      interact
    ''
  );
in
{
  options = {
    nix-utils.enable = lib.mkEnableOption "Helpful nix utils";
  };

  config = lib.mkIf config.nix-utils.enable {
    nix = {
      # package = lib.mkForce pkgs.unstable.nix;
      package = lib.mkForce pkgs.nix;
      settings = {
        warn-dirty = false;
        extra-experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };
      extraOptions = ''
        trusted-users = root ${user}
      '';
      registry = {
        nixpkgs = {
          from = {
            id = "nixpkgs";
            type = "indirect";
          };
          to = {
            owner = "NixOS";
            repo = "nixpkgs";
            type = "github";
            inherit (inputs.nixpkgs) rev;
          };
        };
        unstable = {
          from = {
            id = "unstable";
            type = "indirect";
          };
          to = {
            owner = "NixOS";
            repo = "nixpkgs";
            type = "github";
            inherit (inputs.nixpkgs-unstable) rev;
          };
        };
        my = {
          from = {
            id = "my";
            type = "indirect";
          };
          to = {
            url = "/home/${user}/.config/flake";
            type = "git";
          };
        };
      };
    };

    programs.nh = {
      enable = true;
      package = pkgs.unstable.nh;
      # clean = {
      #   enable = true;
      #   extraArgs = "--keep-since 4d --keep 3";
      # };
      # flake = ../../../.;
      # flake = ./. + builtins.toPath "";
      # flake = /. + builtins.toPath "/home/${config.user}/.config/flake";
    };

    home = {
      packages =
        (with pkgs; [
          # unstable.nixfmt-rfc-style
          unstable.nixfmt

          nix-du
          nix-index # for developing nixpkgs
          nix-tree
          nix-update
          nix-output-monitor
          nvd
          unstable.nixpkgs-review
        ])
        ++ [
          nix-repl # my nix repl wrapper
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          inputs.nixpkgs-update.packages.x86_64-linux.nixpkgs-update
        ];
      sessionVariables.NH_FLAKE = "${config.home.homeDirectory}/.config/flake";
      # sessionVariables.NH_FLAKE = "/home/${user}/.config/flake";
      # sessionVariables.FLAKE = "/home/${config.home.username}/.config/flake";
    };
  };
}
