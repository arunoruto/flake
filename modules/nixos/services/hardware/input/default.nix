{ lib, ... }:
{
  imports = [
    ./kanata.nix
    ./keyboard.nix
    ./keyd.nix
    ./mouse.nix
    ./touchpad.nix
  ];

  services.kanata.enable = lib.mkDefault false;
  services.keyd.enable = lib.mkDefault true;
  touchpad.enable = lib.mkDefault false;
}
