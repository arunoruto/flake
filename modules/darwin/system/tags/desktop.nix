{ lib, config, ... }:
let
  # Darwin modules get a plain lib (no flake `lib.hasTag`), so use a local copy.
  hasTag = tag: lib.elem tag config.system.tags;
in
{
  config = lib.mkIf (hasTag "desktop") {
    # Darwin-specific desktop configurations can go here
    # Main purpose is home-manager propagation via system.tags
  };
}
