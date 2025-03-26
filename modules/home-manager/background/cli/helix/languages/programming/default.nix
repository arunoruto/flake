{ lib, config, ... }:
{
  imports = [
    ./fortran.nix
    ./go.nix
    ./julia.nix
    ./matlab.nix
    ./python.nix
  ];

  helix = {
    julia.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    fortran.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    go.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    matlab.enable = lib.mkDefault (!config.hosts.tinypc.enable);
    python.enable = lib.mkDefault (!config.hosts.tinypc.enable);
  };
}
