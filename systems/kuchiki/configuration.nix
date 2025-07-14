{
  config,
  pkgs,
  lib,
  ...
}:
{
  hosts = {
    amd = {
      enable = true;
      gpu.enable = true;
    };
    nvidia.enable = true;
    zfs.enable = true;
  };
  systemd.services.zfs-mount.enable = false;
  networking.hostId = "7923f829";

  # display-manager.enable = lib.mkForce false;
  # desktop-environment.enable = lib.mkForce false;
  display-manager.enable = false;
  desktop-environment.enable = false;

  # firefox.enable = false;
  # chrome.enable = false;
  # steam.enable = false;
  # home.pc.enable = false;
  programs.enable = false;

  services = {
    traefik.enable = true;
    homepage-dashboard.enable = true;
    media = {
      enable = true;
      dataDir = "/mnt/storage/appdata";
      openFirewall = true;
    };
    syncthing.enable = true;
    # hddfancontrol = {
    #   enable = false;
    #   disks = [
    #     "/dev/sda"
    #     "/dev/sdb"
    #   ];
    #   pwmPaths = [
    #     "/sys/class/hwmon/hwmon2/pwm1"
    #   ];
    # };
    beszel.agent = {
      enable = true;
      package = pkgs.unstable.beszel;
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

  sops.secrets."tokens/beszel-marvin".mode = "0444";
}
