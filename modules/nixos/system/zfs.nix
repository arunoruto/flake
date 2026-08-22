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
      # mkDefault so a host that also enables nvidia (which pins the same
      # kernel) does not hit a duplicate-definition error.
      kernelPackages = lib.mkDefault pkgs.linuxPackages;
      supportedFilesystems = {
        zfs = lib.mkDefault true;
      };
      zfs.forceImportRoot = false;
    };

    services.zfs = {
      autoScrub = {
        enable = lib.mkDefault true;
        interval = lib.mkDefault "*-*-1,15 02:30";
      };

      # Snapshots follow the com.sun:auto-snapshot property, so a dataset opts
      # in by carrying it. Scratch datasets set it false and are skipped -
      # snapshotting scratch is how pools silently fill, since deleted files
      # stay pinned by the snapshots that reference them.
      #
      # Retention pyramid: 1h at 15-minute granularity, then a day of hourly,
      # a fortnight of daily, two months of weekly, six months of monthly.
      # Snapshots only consume space as the data underneath them changes, so a
      # media pool that mostly grows costs almost nothing to keep this deep.
      autoSnapshot = {
        enable = lib.mkDefault true;
        frequent = lib.mkDefault 4;
        hourly = lib.mkDefault 24;
        daily = lib.mkDefault 14;
        weekly = lib.mkDefault 8;
        monthly = lib.mkDefault 6;
        # --utc avoids snapshot name collisions and apparent time reversals
        # across DST changes, as the option documentation recommends.
        flags = lib.mkDefault "-k -p --utc";
      };
    };

  };
}
