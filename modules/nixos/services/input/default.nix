{lib, ...}: {
  imports = [
    ./fingerprint.nix
    ./kanata.nix
    ./touchpad.nix
    ./vial.nix
  ];

  fingerprint.enable = lib.mkDefault false;
  kanata.enable = lib.mkDefault true;
  touchpad.enable = lib.mkDefault false;
  vial.enable = lib.mkDefault false;
}
