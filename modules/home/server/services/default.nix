{ config, lib, ... }:
{
  # imports = [
  #   ./nix-serve.nix
  # ];

  nix-serve.enable = lib.mkDefault (!config.hosts.tinypc.enable);
}
