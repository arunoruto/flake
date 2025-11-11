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
  system.tags = [
    "tinypc"
    "headless"
  ];
  hosts.intel.enable = true;
  bosflix = {
    enable = true;
    drivePath = /media/86336459-5d8c-448e-93c3-f3e17c00d3b9;
  };
  # tpm.enable = true;
  media.external-drives.enable = true;

  services = {
    xserver.desktopManager.kodi.enable = true;
    home-assistant.enable = true;
    zigbee2mqtt.settings.serial = {
      port = "/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0014D9C839-if00";
      adapter = "zstack";
    };
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
    suwayomi-server.enable = true;
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
