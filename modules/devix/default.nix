# devenv target: the devix option schema, every language and addon definition,
# and one adapter per consumer that has a devenv story.
#
# Mirrors targets/home/default.nix — both assemble themselves from the same
# consumer registry, so the two targets cannot drift apart silently.
{ lib, ... }:

let
  consumers = import ./consumers/registry.nix { inherit lib; };
in
{
  imports = [
    ./core
    ./core/renames.nix
    ./languages
    ./addons
  ]
  ++ consumers.devenvModules;
}
