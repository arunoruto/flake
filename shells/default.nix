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
  go = callPackage ./go.nix { };
  go-lsp = callPackage ./go.nix { withLsp = true; };
  website = callPackage ./website.nix { };
}
