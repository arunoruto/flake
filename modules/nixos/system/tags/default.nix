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

  # Tag metadata for colmena's hive so you can target e.g. `--on @desktop`.
  # The colmena binary itself is installed only on `management` machines
  # (see ./management.nix).
  config = lib.optionalAttrs (inputs ? colmena) {
    colmena.deployment.tags = config.system.tags;
  };
}
