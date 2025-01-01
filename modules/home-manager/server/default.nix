{
  config,
  pkgs,
  lib,
  user,
  osConfig,
  ...
}@args:
let
  flake-location = config.home.sessionVariables.FLAKE;
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

  home.packages = with pkgs; [
    speedtest-cli

    dust
    glow
    hexyl
    # hugo
    marksman
    miller
    ncdu
    ouch
    slides

    # nix
    unstable.nh
    nix-du
    nix-tree
    nix-output-monitor
    nvd
  ];
}
