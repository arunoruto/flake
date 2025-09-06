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
  networking.hostId = "b9b3aa87";

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
    tailscale.tsidp = {
      enable = true;
      port = 41443;
      localPort = 41080;
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
  };
}
