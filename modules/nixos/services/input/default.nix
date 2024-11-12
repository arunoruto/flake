{ lib, ... }:
{
  imports = [
    ./kanata.nix
    ./keyd.nix
    ./touchpad.nix
    ./vial.nix
  ];

  services.kanata.enable = lib.mkDefault false;
  services.keyd.enable = lib.mkDefault true;
  touchpad.enable = lib.mkDefault false;
  vial.enable = lib.mkDefault false;
}
