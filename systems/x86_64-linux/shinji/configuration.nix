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
        # videoDrivers here is modesetting, so the module's driver-derived
        # default lands on the empty list and the agent falls back to its own
        # auto-detection, which turns up nothing. Named explicitly: intel_sysfs
        # is the cheaper collector, but on this gen9 UHD 630 i915 sysfs exposes
        # frequency only - engine/*/ carries no busy counters - so utilisation
        # has to come off the PMU, which is intel_gpu_top.
        GPU_COLLECTOR = [ "intel_gpu_top" ];
        # Pins the ATA pass-through type for the two non-NVMe disks. Both were
        # failing the agent's periodic scan - sdb with "smartctl failed ...
        # exit status 2", sda with "no valid SMART data found" - while a manual
        # `smartctl -d sat` returns the full attribute table for either. Note
        # the scans that failed were the ones that ran against idle disks, and
        # a scan taken while they were awake succeeded without this setting, so
        # standby is the likelier culprit and this is belt-and-braces: it costs
        # nothing and stops the agent falling back to the plain scsi type it
        # reports for sda. Merged with the agent's own scan rather than
        # replacing it, so nvme0n1 stays untouched. sda is SMART-only on
        # purpose: its ext4 partition is mounted nowhere, and an
        # EXTRA_FILESYSTEMS entry for an unmounted device is dropped as an
        # invalid filesystem.
        SMART_DEVICES = lib.concatStringsSep "," [
          "/dev/sda:sat"
          "/dev/sdb:sat"
        ];
        # Service health next to the hardware; the module wires up the D-Bus
        # policy the agent needs to call ListUnits.
        SKIP_SYSTEMD = false;
      };
      # EnvironmentFile, not TOKEN_FILE: systemd reads it as root, so the token
      # can stay 0400 instead of the 0444 the agent-read KEY_FILE needs.
      environmentFile = config.sops.templates."beszel-agent.env".path;
      smartmon.enable = true;
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
