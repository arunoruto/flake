{
  lib,
  ...
}:
{
  imports = [
    ./fingerprint.nix
    ./yubikey.nix
  ];

  fingerprint.enable = lib.mkDefault false;
  yubikey.enable = lib.mkDefault false;

  security = {
    polkit.enable = true;
  };
}
