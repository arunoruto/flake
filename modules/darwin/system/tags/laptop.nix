{ lib, config, ... }:
let
  # Darwin modules get a plain lib (no flake `lib.hasTag`), so use a local copy.
  hasTag = tag: lib.elem tag config.system.tags;
in
{
  config = lib.mkIf (hasTag "laptop") {
    # Darwin laptop-specific configurations (battery, power management, etc.)
  };
}
