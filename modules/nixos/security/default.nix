{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./fingerprint.nix
    ./rssh.nix
    ./secrets.nix
    ./tpm
    ./yubikey
  ];

  fingerprint.enable = lib.mkDefault false;
  rssh.enable = lib.mkDefault (!config.yubikey.enable && config.ssh.enable);
  secrets.enable = lib.mkDefault true;
  tpm.enable = lib.mkOptionDefault false;
  yubikey = {
    enable = lib.mkOptionDefault false;
    identifiers = { };
  };

  security = {
    polkit.enable = true;
    sudo.package =
      if config.tinypc.enable then pkgs.sudo else pkgs.sudo.override { withInsults = true; };
  };

  environment.systemPackages = with pkgs; [
    clevis
  ];
}
