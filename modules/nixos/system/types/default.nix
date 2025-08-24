{ lib, ... }:
{
  imports = [
    ./laptop.nix
    ./tinypc.nix
    ./workstation.nix
  ];

  hosts = { };
}
