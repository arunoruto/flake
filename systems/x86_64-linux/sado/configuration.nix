{ config, lib, ... }:
{
  users.primaryUser = "mirza";

  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  system.tags = [
    "nas"
    "server"
  ];

  # colmena.deployment.buildOnTarget = true;
  hosts = {
    intel = {
      enable = true;
      gpu.enable = false;
    };
    zfs.enable = true;
  };
  systemd.services.zfs-mount.enable = false;
  networking = {
    hostId = "b9b3aa87";
    bridges.br0 = {
      interfaces = [
        "enp1s0"
        "enp2s0"
      ];
      rstp = true;
    };
    firewall.trustedInterfaces = [ "br0" ];
    interfaces = {
      br0.useDHCP = true;
    }
    // lib.genAttrs config.networking.bridges.br0.interfaces (name: {
      useDHCP = false;
    });
    networkmanager = {
      unmanaged = map (name: "interface-name:${name}") config.networking.bridges.br0.interfaces;
      # wlo1 and br0 both sit on the LAN subnet. NetworkManager gives wifi a route
      # metric of 600, which beats the 1009 dhcpcd assigns br0, so the host answered
      # br0's own bridge members (the incus VMs) out over the wifi -- an asymmetric
      # path the AP does not hairpin, leaving host <-> VM traffic dead. Push wifi
      # below br0 so the wired bridge wins and the path stays symmetric.
      settings."connection-wifi-lowprio" = {
        match-device = "type:wifi";
        "ipv4.route-metric" = 2000;
        "ipv6.route-metric" = 2000;
      };
    };
  };
  virtualisation.incus = {
    enable = true;
    preseed.profiles = [
      {
        name = "default";
        devices = {
          # enp1s0 = {
          #   name = "enp1s0";
          #   network = "incusbr0";
          #   type = "nic";
          # };
          eth0 = {
            name = "eth0";
            type = "nic";
            nictype = "bridged";
            parent = "br0";
          };
          root = {
            path = "/";
            pool = "zfs-incus";
            type = "disk";
          };
          # rtl = {
          #   vendorid = "0bda";
          #   productid = "2838";
          #   type = "usb";
          #   required = false;
          # };
          slzb-mr3 = {
            vendorid = "10c4";
            productid = "ea60";
            type = "usb";
            required = false;
          };
          slzb-ultima3 = {
            vendorid = "303a";
            productid = "4002";
            type = "usb";
            required = false;
          };
          bt-internal = {
            vendorid = "8087";
            productid = "0026";
            type = "usb";
            required = false;
          };
          bt-external = {
            vendorid = "0b05";
            productid = "190e";
            type = "usb";
            required = false;
          };
        };
      }
    ];
  };

  boot.kernelParams = [
    "pcie_aspm=force"
    "pcie_aspm.policy=powersupersave"
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=200M
    MaxRetentionSec=2week
    MaxFileSec=1day
  '';

  services = {
    media = {
      enable = true;
      dataDir = "/mnt/flash/appdata";
      openFirewall = true;
    };
    cloudflared = {
      enable = true;
      defaultDomain = "arnaut.me";
    };
    tailscale.tsidp = {
      enable = false;
      port = 41443;
      localPort = 41080;
    };
    stump.enable = true;
    mayberry = {
      enable = true;
      libraryPath = "/mnt/flash/books";
      branchName = "cryo-${config.networking.hostName}";
    };
    bindery.enable = true;
    # komga.enable = true;
    # immich = {
    #   enable = true;
    #   mediaLocation = "/mnt/flash/photos";
    # };
    paperless = {
      enable = true;
      dataDir = "/mnt/flash/appdata/paperless";
      mediaDir = "/mnt/flash/documents";
    };
    explo.enable = true;
    ytdlp-bot.enable = true;
    # soulsync.enable = false;
    lidarr = {
      enable = true;
      openFirewall = true;
    };
    plex.enable = true;
    scrutiny.collector = {
      enable = false;
      settings.api.endpoint = "https://scrutiny.bv.e-technik.tu-dortmund.de";
    };
    traefik.enable = true;
    syncthing.enable = true;

    # suwayomi-server = {
    #   enable = false;
    #   openFirewall = true;
    # };
    samba = {
      directories = {
        photos = {
          path = "/mnt/flash/photos";
        };
        documents = {
          path = "/mnt/flash/documents";
        };
        books = {
          path = "/mnt/flash/books";
        };
        music = {
          path = "/mnt/flash/music";
        };
        downloads = {
          path = "/mnt/flash/downloads";
        };
        appdata = {
          path = "/mnt/flash/appdata";
        };
      };
      disableShares = [
        "appdata"
        "downloads"
      ];
    };
    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };
}
