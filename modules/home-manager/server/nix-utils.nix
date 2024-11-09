{
  config,
  lib,
  pkgs,
  user,
  osConfig,
  ...
}@args:
let
  nix-repl = pkgs.writeScriptBin "nix-repl" (
    ''
      #!${lib.getExe pkgs.expect}

      spawn nix repl
      expect {
        "Welcome to Nix" {}
        -r "Nix (\\d+\\.\\d+\\.\\d+)" {}
      }
      send -- ":lf ${config.home.sessionVariables.FLAKE}\r"
      expect -r "Added (\\d+) variables."
      send -- ":lf nixpkgs\r"
      expect -r "Added (\\d+) variables."
      send -- "pkgs = legacyPackages.${pkgs.system}\r"
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
    nixd-config = lib.mkOption rec {
      type = lib.types.attrs;
      default = {
        nixpkgs.expr = "import <nixpkgs> { }";
        formatting.command = [ "nixfmt" ];
        options = {
          nixos.expr = "";
          home-manager.expr = "";
        };
        diagnostics.supress = [ ];
      };
      example = default;
      description = "Configuration of nixd which will be used across multiple IDEs";
    };
  };

  config = lib.mkIf config.nix-utils.enable {
    nix = {
      package = lib.mkForce pkgs.unstable.nix;
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      # extraOptions = ''
      #   trusted-users = root ${user}
      # '';
    };

    home.packages =
      (with pkgs; [
        unstable.nixfmt-rfc-style

        unstable.nh
        nix-du
        nix-index # for developing nixpkgs
        nix-tree
        nix-output-monitor
        nvd
        unstable.nixpkgs-review
      ])
      ++ [
        nix-repl # my nix repl wrapper
      ];
  };
}
