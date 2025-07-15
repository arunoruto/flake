{ lib, ... }:
{
  imports = [
    ./sound.nix
  ];

  services.pipewire.enable = lib.mkDefault true;
}
