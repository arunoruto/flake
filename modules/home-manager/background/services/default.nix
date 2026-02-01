{ config, lib, pkgs, ... }:
{
  imports = [
    ./nix-serve.nix
    ./nixai.nix
  ];

  programs.nix-serve.enable = lib.mkDefault (!config.hosts.tinypc.enable && pkgs.stdenv.hostPlatform.isLinux);
}
