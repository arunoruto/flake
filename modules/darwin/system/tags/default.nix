{ config, lib, ... }:
{
  imports = [
    ./desktop.nix
    ./laptop.nix
  ];

  options = {
    system.tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of tags for this Darwin system";
      example = [
        "desktop"
        "laptop"
      ];
    };
  };

  # Expose `config.lib.tags.hasTag "<tag>"` to all modules (stylix-style
  # `config.lib` pattern). LHS `lib.tags` is the option; RHS `lib` the library.
  config.lib.tags.hasTag = import ../../../../lib/has-tag.nix lib config;
}
