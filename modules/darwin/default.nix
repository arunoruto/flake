{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./system
    ./security
    ./homebrew
    ./users
    ../../homes/nixos.nix
  ];
}
