{ lib, ... }:
{
  imports = [
    ./beszel.nix
    ./fw-fanctrl.nix
    ./fwupd.nix
    ./keyboard.nix
    ./mouse.nix
    ./printing.nix
    ./scanning.nix
    ./ssd.nix
    ./suid.nix
  ];

  fwupd.enable = lib.mkDefault true;
  printing.enable = lib.mkDefault false;
  scanning.enable = lib.mkDefault false;

  drive-optimizations.enable = lib.mkDefault true;
  suid.enable = lib.mkDefault true;
  # ssd.enable = lib.mkDefault true;
}
