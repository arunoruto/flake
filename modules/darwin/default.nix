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
    ./keyboard
    ./users
    ../../homes/nixos.nix
  ];
}
