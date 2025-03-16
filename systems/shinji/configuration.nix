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
      domainPath = config.sops.secrets."tokens/ipv64/orahovica".path;
      keyPath = config.sops.secrets."tokens/ipv64/orahovica".key;
    };
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
