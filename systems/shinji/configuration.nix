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
  bosflix = {
    enable = true;
    drivePath = /media/86336459-5d8c-448e-93c3-f3e17c00d3b9;
  };
  # tpm.enable = true;
  media.external-drives.enable = true;

  plex.enable = true;
  services.plex.accelerationDevices = [ "/dev/dri/renderD128" ];
  services = {
    xrdp = {
      enable = true;
      defaultWindowManager = "kodi";
    };
    ipv64-dyndns = {
      enable = true;
      domainKeyPath = config.sops.secrets."tokens/ipv64/orahovica".path;
    };
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
