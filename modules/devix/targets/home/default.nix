# Home Manager target: the devix option schema, every language definition, the
# shared package/assertion handling, and one adapter per registered consumer.
{ lib, ... }:

let
  consumers = import ../../consumers/registry.nix { inherit lib; };
in
{
  imports = [
    ../../core
    ../../core/renames.nix
    ../../languages
    ../../addons
    ./auto-enable.nix
    ./editor-env.nix
    ./packages.nix
  ]
  ++ consumers.homeModules;
}
