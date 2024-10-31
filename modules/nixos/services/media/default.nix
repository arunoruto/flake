{ lib, ... }:
{
  imports = [
    ./sound.nix
  ];

  pipewire.enable = lib.mkDefault true;
}
