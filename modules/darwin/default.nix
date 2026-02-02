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
    ./keyboard
    ./users
    ../../homes/nixos.nix
  ];
}
