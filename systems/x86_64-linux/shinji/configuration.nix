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

  system.tags = [ "server" ];

  colmena.deployment = {
    targetHost = config.networking.hostName;
  };
  boot.kernelPackages = pkgs.linuxPackages;
  hosts.intel.enable = true;
  # tpm.enable = true;

  services = {
    bosflix = {
      enable = true;
      drivePath = /media/downloads;
    };
    devmon.enable = true; # automount external drives
    xserver.desktopManager.kodi.enable = true;
    home-assistant.enable = false;
    zigbee2mqtt = {
      enable = false;
      settings.serial = {
        # port = "/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0014D9C839-if00";
        port = "/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-06p7_7af5d4d1efa5ed11b1cbf1a32981d5c7-if00-port0";
        adapter = "zstack";
      };
    };
    cloudflared.enable = true;
    traefik.enable = true;
    # Websocket rather than the SSH method the other hosts use: the hub sits on
    # the work network and this host is behind NAT on the personal tailnet, so
    # it has to dial out. Nothing listens here and the firewall stays shut.
    beszel.agent = {
      enable = true;
      package = pkgs.unstable.beszel;
      environment = {
        LOG_LEVEL = "info";
        HUB_URL = "https://infra.bv.e-technik.tu-dortmund.de";
        # Identifies us to the hub; still required in websocket mode.
        KEY_FILE = config.sops.secrets."tokens/beszel-marvin".path;
        # Keyed by device, not by the mount path: /media/downloads is nofail
        # plus x-systemd.automount, and a path here becomes a RequiresMountsFor
        # that would hold the agent down whenever the drive is unplugged.
        EXTRA_FILESYSTEMS = "sdb1";
      };
      # EnvironmentFile, not TOKEN_FILE: systemd reads it as root, so the token
      # can stay 0400 instead of the 0444 the agent-read KEY_FILE needs.
      environmentFile = config.sops.templates."beszel-agent.env".path;
    };
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
    # microsocks = {
    #   enable = true;
    #   ip = "100.105.115.20";
    # };
    qbittorrent.enable = true;
    sabnzbd.enable = true;
    suwayomi-server.enable = false;
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
  users.groups.media = {
    gid = 420;
    members = [ config.users.primaryUser ];
  };

  sops = {
    # The hub's public key; the agent process reads this one itself.
    secrets."tokens/beszel-marvin".mode = "0444";
    secrets."tokens/beszel-ws" = { };
    templates."beszel-agent.env".content = ''
      TOKEN=${config.sops.placeholder."tokens/beszel-ws"}
    '';
  };
}
