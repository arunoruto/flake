{ lib, ... }:
{
  imports = [
    ./nix-serve.nix
  ];

  nix-serve.enable = lib.mkDefault true;
}
