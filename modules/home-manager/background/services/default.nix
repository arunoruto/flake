{ config, lib, ... }:
{
  imports = [
    ./nix-serve.nix
    ./nixai.nix
  ];

  nix-serve.enable = lib.mkDefault (!config.hosts.tinypc.enable);
}
