{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}@args:
let
  user = config.user;
  flake-location = config.home.sessionVariables.NH_FLAKE;
in
{
  imports = [
    ./cli
    ./programs
    ./services
    ./shell

    ./nix-utils.nix
    ./secrets.nix
    ./ssh.nix
  ];

  nix-utils.enable = true;
  ssh.enable = true;

  nixd-config = {
    nixpkgs.expr = "import (builtins.getFlake ''${flake-location}'').inputs.nixpkgs { }";
    formatting.command = [ "nixfmt" ];
    options = {
      nixos.expr =
        lib.optionalString (args ? nixosConfig)
          "(builtins.getFlake ''${flake-location}'').nixosConfigurations.${osConfig.networking.hostName}.options";
      home-manager.expr = "(builtins.getFlake ''${flake-location}'').homeConfigurations.${user}.options";
    };
    diagnostics = { };
  };

  home.packages =
    with pkgs;
    [
      dust
      dysk
      speedtest-cli
    ]
    ++ lib.optionals (!config.hosts.tinypc.enable) (
      with pkgs;
      [

        glow
        hexyl
        miller
        ncdu
        ouch
        slides
      ]
    );
}
