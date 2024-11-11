{ lib, ... }:
{
  imports = [
    ./laptop.nix
    ./tinypc.nix
    ./workstation.nix
  ];

  hosts = {
    laptop.enable = lib.mkDefault false;
    tinypc.enable = lib.mkDefault false;
    workstation.enable = lib.mkDefault false;
  };
}
