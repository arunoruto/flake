{
  config,
  pkgs,
  lib,
  ...
}:
{
  colmena.deployment = {
    targetHost = config.networking.hostName;
    tags = [ "tinypc" ];
  };
  hosts.tinypc.enable = true;
  hosts.intel.enable = true;
  kodi.enable = true;
  bosflix.enable = true;
  # tpm.enable = true;

  services = {
    udisks2.enable = true;
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
