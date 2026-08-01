{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../../../shared/tags.nix
    ./desktop.nix
    ./gaming.nix
    ./laptop.nix
    ./workstation.nix
    ./management.nix
    ./server.nix
  ];

  # Tag metadata for colmena's hive so you can target e.g. `--on @desktop`.
  # The colmena binary itself is installed only on `management` machines
  # (see ./management.nix).
  config = lib.optionalAttrs (inputs ? colmena) {
    colmena.deployment.tags = config.system.tags;
  };
}
