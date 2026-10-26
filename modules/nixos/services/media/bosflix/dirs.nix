{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.bosflix;
  syncthingCfg = config.services.syncthing;

  # Everything on the drive is shared between the downloaders, syncthing and
  # the *arrs, so it all gets the same setgid + group-writable treatment.
  sharedPaths = [
    cfg.completedPath
    cfg.incompletedPath
  ]
  ++ map (name: "${cfg.completedPath}/${name}") cfg.syncedFolders;
in
{
  config = lib.mkIf cfg.enable {
    # What the nightly clamdscan sweeps when a host turns it on: everything
    # that leaves the box via syncthing, both users' folders alike.
    services.clamav.scanner.scanDirectories = lib.mkDefault [ cfg.completedPath ];

    systemd.services = {
      # Same autofs story as bosflix-dirs: pull the drive in (or fail the run
      # if it is unplugged) instead of scanning an empty mountpoint.
      clamdscan = lib.mkIf config.services.clamav.scanner.enable {
        unitConfig.RequiresMountsFor = [ cfg.completedPath ];
      };

      # The drive is an autofs mount (`x-systemd.automount`) and
      # systemd-tmpfiles refuses to traverse autofs mount points: at boot it
      # logs "Detected autofs mount point '<drivePath>' ... Skipping" for every
      # rule below it, so these directories were never actually created or
      # fixed up. They ended up root-umask 2755, which locks out the rest of
      # the `media` group — sabnzbd above all. Do it from a unit that pulls the
      # mount in itself instead.
      bosflix-dirs = {
        description = "Create bosflix download directories";
        wantedBy = [ "multi-user.target" ];
        before =
          lib.optional config.services.sabnzbd.enable "sabnzbd.service"
          ++ lib.optional config.services.qbittorrent.enable "qbittorrent.service"
          ++ lib.optional config.services.syncthing.enable "syncthing.service";
        unitConfig.RequiresMountsFor = [
          cfg.completedPath
          cfg.incompletedPath
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = [ pkgs.coreutils ];
        # setgid so anything created underneath inherits the `media` group,
        # group-writable so every member of that group (sabnzbd, qbittorrent,
        # syncthing, the *arrs) can write into the shared folders. Those
        # services all run with UMask=0002, which keeps the group-write bit on
        # the directories they create in turn.
        #
        # Note sabnzbd undoes the setgid bit on its *own* final folders unless
        # misc.permissions keeps it; see ./sabnzbd.nix.
        script = ''
          install -d -o ${config.users.primaryUser} -g ${cfg.mediaGroup} -m 0775 ${lib.escapeShellArg cfg.drivePath}
          install -d -o root -g ${cfg.mediaGroup} -m 2775 ${lib.escapeShellArgs sharedPaths}
        ''
        + lib.optionalString config.services.syncthing.enable ''
          install -d -o ${syncthingCfg.user} -g ${syncthingCfg.group} -m 0755 ${lib.escapeShellArg "${cfg.completedPath}/.stfolder"}
        '';
      };
    };
  };
}
