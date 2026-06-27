{ lib, ... }:
{
  imports = [
    ./komga.nix
    ./stump.nix
    ./manga.nix
    ./paperless.nix
  ];
}
