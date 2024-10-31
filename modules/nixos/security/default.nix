{
  lib,
  ...
}:
{
  imports = [
    ./fingerprint.nix
    ./secrets.nix
    ./yubikey.nix
  ];

  fingerprint.enable = lib.mkDefault false;
  secrets.enable = lib.mkDefault true;
  yubikey.enable = lib.mkDefault false;

  security = {
    polkit.enable = true;
  };
}
