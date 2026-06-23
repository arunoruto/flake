{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./desktop.nix
    ./laptop.nix
    ./workstation.nix
    ./management.nix
  ];

  options.system.tags = lib.mkOption {
    # type = lib.types.listOf lib.types.str;
    type = with lib.types; listOf str;
    default = [ ];
    description = ''
      List of tags for this system. This can be used to identify
      this system in scripts or other tools.
    '';
  };

  config = lib.mkMerge [
    # Expose `config.lib.tags.hasTag "<tag>"` to all modules (the stylix-style
    # `config.lib` option pattern). LHS `lib.tags` is the option; RHS `lib` is
    # the function library.
    { lib.tags.hasTag = import ../../../../lib/has-tag.nix lib config; }

    # Tag metadata for colmena's hive so you can target e.g. `--on @desktop`.
    # The colmena binary itself is installed only on `management` machines
    # (see ./management.nix).
    (lib.optionalAttrs (inputs ? colmena) {
      colmena.deployment.tags = config.system.tags;
    })
  ];
}
