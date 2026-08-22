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
    zfs.enable = true;
  };
  systemd.services.zfs-mount.enable = false;
  # Unique to this host - must not match kuchiki, or ZFS cannot tell
  # the two apart when a pool is imported.
  networking.hostId = "2dc03b5d";

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
      package = pkgs.unstable.beszel;
      # package = pkgs.custom.beszel;
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
      # hwmon indices are assigned in module-load order and are NOT stable: the
      # ZFS kernel switch moved coretemp from hwmon5 to hwmon4 and fancontrol
      # refused to start. @IT@/@CT@ are resolved by chip name at service start
      # (see systemd.services.fancontrol below) so a reshuffle cannot break it.
      config = ''
        INTERVAL=10
        DEVPATH=@IT@=devices/platform/it87.2624 @CT@=devices/platform/coretemp.0
        DEVNAME=@IT@=it8622 @CT@=coretemp
        FCTEMPS=@IT@/pwm3=@CT@/temp1_input
        FCFANS=@IT@/pwm3=@IT@/fan3_input
        MINTEMP=@IT@/pwm3=20
        MAXTEMP=@IT@/pwm3=60
        MINSTART=@IT@/pwm3=150
        MINSTOP=@IT@/pwm3=100
      '';
    };
  };

  systemd.services.fancontrol.serviceConfig.ExecStart = lib.mkForce (
    let
      template = pkgs.writeText "fancontrol.conf.in" config.hardware.fancontrol.config;
    in
    pkgs.writeShellScript "fancontrol-resolve" ''
      set -eu
      hw() {
        for d in /sys/class/hwmon/hwmon*; do
          if [ "$(cat "$d/name" 2>/dev/null)" = "$1" ]; then
            basename "$d"
            return 0
          fi
        done
        echo "fancontrol: hwmon chip '$1' not present" >&2
        exit 1
      }
      IT=$(hw it8622)
      CT=$(hw coretemp)
      echo "fancontrol: it8622=$IT coretemp=$CT"
      ${pkgs.gnused}/bin/sed -e "s|@IT@|$IT|g" -e "s|@CT@|$CT|g" ${template} >/run/fancontrol.conf
      exec ${pkgs.lm_sensors}/bin/fancontrol /run/fancontrol.conf
    ''
  );

  sops.secrets."tokens/beszel-marvin".mode = "0444";
}
