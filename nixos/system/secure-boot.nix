{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options = {
    secureboot.enable = lib.mkEnableOption "Enable lanzaboote for secure booting the system";
  };

  config = lib.mkIf config.secureboot.enable {
    environment.systemPackages = [pkgs.sbctl];
    boot = {
      loader.systemd-boot.enable = lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
