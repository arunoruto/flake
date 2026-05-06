# Shell definitions using callPackage pattern
# Each shell only declares the arguments it actually needs
{
  pkgs,
  lib,
  self,
  inputs,
}:

let
  # Create a scope with common arguments available
  callPackage = pkgs.newScope { inherit lib self inputs; };
in
{
  # Vanilla shells - simple and lightweight
  go = callPackage ./go.nix { };
  website = callPackage ./website.nix { };

  # Devenv shells - managed separately for clarity
  # python = callPackage ./python.nix { };
}
