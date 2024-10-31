{ lib, ... }:
{
  imports = [
    ./kanata.nix
    ./touchpad.nix
    ./vial.nix
  ];

  kanata.enable = lib.mkDefault true;
  touchpad.enable = lib.mkDefault false;
  vial.enable = lib.mkDefault false;
}
