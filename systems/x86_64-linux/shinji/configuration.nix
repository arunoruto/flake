{
  config,
  pkgs,
  lib,
  ...
}:
let
  target-folder = "/media/downloads";
in
{
  users.primaryUser = "mirza";

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
    drivePath = /media/downloads;
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
    qbittorrent.enable = true;
    sabnzbd.enable = true;
    suwayomi-server.enable = true;
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

  fileSystems."${target-folder}" = {
    device = "/dev/disk/by-uuid/86336459-5d8c-448e-93c3-f3e17c00d3b9";
    fsType = "ext4"; # or ntfs, exfat, etc.
    options = [
      "nofail" # Very important: allows PC to boot even if drive is unplugged
      "x-systemd.automount" # Mounts it when you access the folder
      "rw"
    ];
  };
  systemd.tmpfiles.rules = [
    "d ${target-folder} 0775 mirza media -"
  ];
  users.groups.media = {
    gid = 420;
    members = [ config.users.primaryUser ];
  };
}
