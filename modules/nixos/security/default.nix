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
    ./yubikey
  ];

  fingerprint.enable = lib.mkDefault false;
  rssh.enable = lib.mkDefault (!config.yubikey.enable && config.ssh.enable);
  secrets.enable = lib.mkDefault true;
  yubikey = {
    enable = lib.mkDefault false;
    identifiers = { };
  };

  security = {
    polkit.enable = true;
  };
}
