# Stylix-style consumer attachment: every consumer switches itself on when its
# own program is enabled and `devix.autoEnable` holds. Derived
# from the registry, so a new consumer needs no wiring here.
{ config, lib, ... }:

let
  consumers = import ../../consumers/registry.nix { inherit lib; };
  cfg = config.devix;
in
{
  config.devix.consumers = lib.mapAttrs (_: entry: {
    enable = lib.mkDefault (cfg.autoEnable && entry.activeWhen config);
  }) consumers.entries;
}
