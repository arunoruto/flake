# Shared by NixOS and Darwin: the `system.tags` option and the
# `config.lib.tags.hasTag` predicate (stylix-style `config.lib` pattern).
# The platform tag modules import this and add their own leaves.
{ config, lib, ... }:
{
  options.system.tags = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "desktop"
      "development"
    ];
    description = ''
      Capability tags for this host. Modules gate on them via
      `config.lib.tags.hasTag "<tag>"`.
    '';
  };

  # LHS `lib.tags` is the option; RHS `lib` is the function library.
  config.lib.tags.hasTag = import ../../lib/has-tag.nix lib config [
    "system"
    "tags"
  ];
}
