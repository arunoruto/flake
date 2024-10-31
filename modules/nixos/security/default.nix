{
  lib,
  config,
  ...
}:
{
  imports = [
    ./fingerprint.nix
    ./rssh.nix
    ./secrets.nix
    ./yubikey.nix
  ];

  fingerprint.enable = lib.mkDefault false;
  rssh.enable = lib.mkDefault config.yubikey.enable;
  secrets.enable = lib.mkDefault true;
  yubikey = {
    enable = lib.mkDefault false;
    identifiers = { };
  };

  security = {
    polkit.enable = true;
  };
}
