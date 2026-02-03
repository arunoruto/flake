{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    nix = {
      enable = lib.mkDefault false;
      settings = {
        warn-dirty = lib.mkDefault false;
        accept-flake-config = lib.mkDefault true;
        trusted-users = lib.mkDefault [
          "root"
          "@wheel"
        ];
        extra-experimental-features = lib.mkDefault [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };
    };
  };
}
