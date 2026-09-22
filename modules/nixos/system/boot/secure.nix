# Lanzaboote secure boot, applied whenever `boot.lanzaboote.enable` is on:
# replaces systemd-boot and uses the PKI bundle under /etc/secureboot (see
# docs/iso.md for enrolling keys).
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = lib.mkIf config.boot.lanzaboote.enable {
    environment.systemPackages = [ pkgs.sbctl ];
    boot = {
      loader.systemd-boot.enable = lib.mkForce false;
      lanzaboote.pkiBundle = "/etc/secureboot";
    };
  };
}
