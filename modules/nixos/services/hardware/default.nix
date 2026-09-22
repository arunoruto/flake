{ lib, ... }:
{
  imports = [
    ./beszel.nix
    ./fwupd.nix
    ./input
    ./printing.nix
  ];

  # On for every host unless it opts out; printing.nix and fwupd.nix add
  # their settings whenever the upstream service is on. (Scanning needs no
  # module: services.ipp-usb turns on SANE and the airscan backend itself.)
  services = {
    fwupd.enable = lib.mkDefault true;
    fstrim.enable = lib.mkDefault true;
  };
}
