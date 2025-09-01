{
  config,
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}@args:
let
  user = config.user;
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
      # send -- {pkgs = import inputs.nixpkgs { system = "${pkgs.system}"; overlays = [ overlays.unstable-packages overlays.additions overlays.python overlays.kodi ]; }}
      # send -- "\r"
      send -- "hm = homeConfigurations.${config.home.username}\r"
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
          # "pipe-operators"
        ];
        # extra-substituters = [
        #   "https://helix.cachix.org"
        #   "https://wezterm.cachix.org"
        # ];
        # extra-trusted-public-keys = [
        #   "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        #   "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        # ];
      };
      extraOptions = ''
        trusted-users = root ${user}
      '';
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
          unstable.nixfmt-rfc-style

          nix-du
          nix-index # for developing nixpkgs
          nix-tree
          nix-update
          nix-output-monitor
          nvd
          unstable.nixpkgs-review
          inputs.nixpkgs-update.packages.x86_64-linux.nixpkgs-update
        ])
        ++ [
          nix-repl # my nix repl wrapper
        ];
      sessionVariables.NH_FLAKE = "/home/${user}/.config/flake";
      # sessionVariables.FLAKE = "/home/${config.home.username}/.config/flake";
    };
  };
}
