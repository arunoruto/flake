_: {
  # colmena.deployment.buildOnTarget = true;
  system.tags = [
    "tinypc"
    "headless"
  ];
  hosts = {
    intel = {
      enable = true;
      gpu.enable = true;
    };
    zfs.enable = true;
  };
  systemd.services.zfs-mount.enable = false;
  networking = {
    hostId = "b9b3aa87";
    # bridges.br0 = {
    #   interfaces = [ "enp1s0" ];
    # };
  };
  virtualisation.incus = {
    enable = true;
    preseed.profiles = [
      {
        name = "default";
        devices = {
          enp1s0 = {
            name = "enp1s0";
            network = "incusbr0";
            type = "nic";
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
          bt = {
            vendorid = "8087";
            productid = "0026";
            type = "usb";
            required = false;
          };
        };
      }
    ];
  };

  display-manager.enable = false;
  desktop-environment.enable = false;
  programs.enable = false;

  boot.kernelParams = [
    "pcie_aspm=force"
    "pcie_aspm.policy=powersupersave"
  ];

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
      enable = true;
      port = 41443;
      localPort = 41080;
    };
    komga = {
      enable = true;
    };
    immich = {
      enable = true;
      # dataDir = "/mnt/flash/appdata/paperless";
      # environment.UPLOAD_LOCATION = "/mnt/flash/photos";
      mediaLocation = "/mnt/flash/photos";
    };
    paperless = {
      enable = true;
      dataDir = "/mnt/flash/appdata/paperless";
      mediaDir = "/mnt/flash/documents";
    };
    scrutiny.collector = {
      enable = true;
      settings.api.endpoint = "https://scrutiny.bv.e-technik.tu-dortmund.de";
    };
    traefik.enable = true;
    syncthing.enable = true;

    tlp.enable = true;
    power-profiles-daemon.enable = false;
    home-assistant.enable = false;
    suwayomi-server = {
      enable = true;
      openFirewall = true;
    };
    pipewire.enable = false;
  };
}
