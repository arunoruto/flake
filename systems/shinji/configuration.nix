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

  plex.enable = true;
  services.plex.accelerationDevices = [ "/dev/dri/renderD128" ];
  services = {
    devmon.enable = true;
    udisks2.enable = true;
    xrdp = {
      enable = true;
      defaultWindowManager = "kodi";
    };
    # x2goserver.enable = true;
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
