{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.hosts.zfs.enable = lib.mkEnableOption "Enable ZFS config for host";

  config = lib.mkIf config.hosts.zfs.enable {
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages;
      supportedFilesystems = {
        zfs = lib.mkDefault true;
      };
      zfs.forceImportRoot = false;
    };

    services.zfs.autoScrub = {
      enable = lib.mkDefault true;
      interval = lib.mkDefault "*-*-1,15 02:30";
    };

  };
}
