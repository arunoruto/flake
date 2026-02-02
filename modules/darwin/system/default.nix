{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./defaults.nix
    ./nix.nix
  ];
}
