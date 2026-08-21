{
  config,
  pkgs,
  lib,
  ...
}:
{
  users.primaryUser = "mirza";

  system.tags = [
    "nas"
    "server"
  ];
  # nixpkgs.overlays = [
  #   (self: super: {
  #     it87 = super.it87.overrideAttrs (old: {
  #       version = "unstable-2025-07-22";
  #       src = self.fetchFromGitHub {
  #         owner = "frankcrawford";
  #         repo = "it87";
  #         rev = "4bff981a91bf9209b52e30ee24ca39df163a8bcd";
  #         hash = "";
  #       };
  #     });
  #   })
  # ];

  boot = {
    kernelModules = [ "it87" ];
    # Force the it87 driver to load for the unrecognized ITE IT8688E chip
    extraModprobeConfig = ''
      options it87 ignore_resource_conflict=1 force_id=0x8622
    '';
    # extraModulePackages = [
    #   (config.boot.kernelPackages.it87.overrideAttrs (oldAttrs: {
    #     version = "unstable-2025-07-22";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "frankcrawford";
    #       repo = "it87";
    #       rev = "4bff981a91bf9209b52e30ee24ca39df163a8bcd";
    #       hash = "sha256-hjNph67pUaeL4kw3cacSz/sAvWMcoN2R7puiHWmRObM=";
    #     };
    #   }))
    # ];
    # extraModulePackages = [ config.boot.kernelPackages.it87 ];
  };

  hosts = {
    intel = {
      enable = true;
      gpu.enable = true;
    };
    nvidia.enable = true;
    # zfs.enable = true;
  };
  # systemd.services.zfs-mount.enable = false;
  # networking.hostId = "7923f829";

  services = {
    scrutiny.collector = {
      enable = true;
      settings.api.endpoint = "https://scrutiny.bv.e-technik.tu-dortmund.de";
    };
    # traefik.enable = true;
    # homepage-dashboard.enable = true;
    # media = {
    #   enable = true;
    #   dataDir = "/mnt/storage/appdata";
    #   openFirewall = true;
    # };
    # syncthing.enable = true;

    hddfancontrol = {
      enable = true;
      settings.hdds = {
        disks = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/sdc"
        ];
        pwmPaths = [ "/sys/class/hwmon/hwmon2/pwm2:25:10" ];
      };
    };
    beszel.agent = {
      enable = true;
      package = pkgs.custom.beszel;
      environment = {
        LOG_LEVEL = "info";
        GPU = "true";
        KEY_FILE = config.sops.secrets."tokens/beszel-marvin".path;
        EXTRA_FILESYSTEMS = lib.strings.concatStringsSep "," [
          "nvme0n1p1"
          "/mnt/storage"
          "/mnt/storage/media"
        ];
      };
      openFirewall = true;
    };
  };

  hardware = {
    fancontrol = {
      enable = true;
      config = ''
        INTERVAL=10
        DEVPATH=hwmon2=devices/platform/it87.2624 hwmon5=devices/platform/coretemp.0
        DEVNAME=hwmon2=it8622 hwmon5=coretemp
        FCTEMPS=hwmon2/pwm3=hwmon5/temp1_input
        FCFANS= hwmon2/pwm3=hwmon2/fan3_input
        MINTEMP=hwmon2/pwm3=20
        MAXTEMP=hwmon2/pwm3=60
        MINSTART=hwmon2/pwm3=150
        MINSTOP=hwmon2/pwm3=100
      '';
    };
  };

  sops.secrets."tokens/beszel-marvin".mode = "0444";
}
