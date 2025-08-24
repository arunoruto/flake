{
  config,
  pkgs,
  lib,
  ...
}:
{
  colmena.deployment = {
    targetHost = config.networking.hostName;
  };
  system.tags = [ "tinypc" ];
  hosts.intel.enable = true;
  kodi.enable = true;
  bosflix = {
    enable = true;
    drivePath = /media/86336459-5d8c-448e-93c3-f3e17c00d3b9;
  };
  # tpm.enable = true;
  media.external-drives.enable = true;

  services = {
    cloudflared.enable = true;
    traefik.enable = true;
    plex = {
      enable = true;
      accelerationDevices = [ "/dev/dri/renderD128" ];
    };
    xrdp = {
      enable = true;
      defaultWindowManager = "kodi";
    };
    ipv64-dyndns = {
      enable = true;
      domainKeyPath = config.sops.secrets."tokens/ipv64/orahovica".path;
    };
    qbittorrent = {
      enable = true;
      webuiPort = 8081;
    };
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
