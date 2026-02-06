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
    ./services
    ./homebrew
    ./users
    ../../homes/nixos.nix
  ];
}
