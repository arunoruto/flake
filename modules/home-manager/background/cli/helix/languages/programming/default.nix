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
    julia.enable = lib.mkDefault config.hosts.development.enable;
    fortran.enable = lib.mkDefault config.hosts.development.enable;
    go.enable = lib.mkDefault config.hosts.development.enable;
    matlab.enable = lib.mkDefault config.hosts.development.enable;
    python.enable = lib.mkDefault config.hosts.development.enable;
  };
}
