# Every NixOS host upgrades itself from GitHub: CI bumps flake.lock in a PR,
# builds every host and merges it before the hosts wake up. See
# docs/auto-upgrade.md. Opt a host out with `system.autoUpgrade.enable = false;`.
{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.system.autoUpgrade;
  host = config.networking.hostName;
  # Topic URL (https://ntfy.sh/<secret topic>) that skips and failures go to.
  ntfyCredential = "ntfy:${config.sops.secrets."tokens/ntfy/upgrade".path}";

  guard = pkgs.writeShellApplication {
    name = "nixos-upgrade-guard";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
    ];
    runtimeEnv = {
      REPO = cfg.repo;
      BRANCH = cfg.branch;
      HOST = host;
    };
    text = builtins.readFile ./upgrade-guard.sh;
  };

  # A rollback restores the old code, not data an app has already migrated,
  # so take a copy just before each upgrade. Services add their own data
  # (pocket-id.nix, immich.nix, stump.nix); a failed backup fails the upgrade.
  bk = cfg.backup;
  pg = config.services.postgresqlBackup;
  pgUnits = lib.optionals pg.enable (
    if pg.backupAll then
      [ "postgresqlBackup.service" ]
    else
      map (db: "postgresqlBackup-${db}.service") pg.databases
  );
  backupDir = "/var/backup/pre-upgrade";
  backup = pkgs.writeShellApplication {
    name = "nixos-upgrade-backup";
    runtimeInputs = [
      pkgs.sqlite
      config.systemd.package
    ]
    ++ lib.optional (bk.zfsDatasets != [ ]) config.boot.zfs.package;
    text = ''
      # Oneshot units: `start` returns once the dump is written.
      units=(${lib.escapeShellArgs pgUnits})
      for unit in "''${units[@]}"; do
        systemctl start "$unit"
      done

      mkdir -p ${backupDir}
      dbs=(${lib.escapeShellArgs bk.sqliteDatabases})
      for db in "''${dbs[@]}"; do
        dest="${backupDir}/$(basename "$db")"
        if [[ -e $dest ]]; then mv "$dest" "$dest.prev"; fi
        sqlite3 "$db" ".backup '$dest'"
      done

      stamp=$(date -u +%Y%m%dT%H%M%SZ)
      datasets=(${lib.escapeShellArgs bk.zfsDatasets})
      for ds in "''${datasets[@]}"; do
        zfs snapshot "$ds@pre-upgrade-$stamp"
        zfs list -H -t snapshot -d 1 -o name -s creation "$ds" | grep '@pre-upgrade-' |
          head -n -${toString bk.keepSnapshots} | xargs -r -n1 zfs destroy
      done
    '';
  };
in
{
  options.system.autoUpgrade = {
    repo = lib.mkOption {
      type = lib.types.str;
      default = "arunoruto/flake";
      description = "GitHub `owner/name` the hosts upgrade from.";
    };
    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Branch the hosts upgrade from.";
    };
    backup = {
      sqliteDatabases = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "SQLite databases copied to ${backupDir}/<file name> before each upgrade (the previous copy is kept as .prev).";
      };
      zfsDatasets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "ZFS datasets snapshotted as <dataset>@pre-upgrade-<UTC time> before each upgrade, after the database dumps.";
      };
      keepSnapshots = lib.mkOption {
        type = lib.types.ints.positive;
        default = 7;
        description = "How many pre-upgrade snapshots to keep per dataset.";
      };
    };
  };

  config = lib.mkMerge [
    {
      # The commit a system was built from: `nixos-version --configuration-revision`.
      # A dirty tree gives `<rev>-dirty`, which the upgrade guard refuses to replace.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.autoUpgrade.enable = lib.mkDefault true;
    }
    (lib.mkIf cfg.enable {
      system.autoUpgrade = {
        # Follow the branch (with its committed flake.lock, validated by CI)
        # instead of a frozen store snapshot of the source. Referencing
        # inputs.self.outPath here would also embed the whole flake source in
        # the system closure. No --update-input: CI owns the lock file, and the
        # module already adds --refresh for flakes.
        flake = "github:${cfg.repo}/${cfg.branch}#${config.networking.hostName}";
        flags = [ "--print-build-logs" ];
        # Local time. CI starts at 01:17 UTC, so its merge lands before this
        # in both CET and CEST.
        dates = "05:00";
        randomizedDelaySec = "30min";
        persistent = true;
      };

      sops.secrets."tokens/ntfy/upgrade" = { };

      # The upstream unit is already after/wants network-online.target.
      systemd.services.nixos-upgrade = {
        unitConfig.OnFailure = [ "nixos-upgrade-failed.service" ];
        serviceConfig = {
          ExecCondition = lib.getExe guard;
          LoadCredential = [ ntfyCredential ];
          ExecStartPre = lib.mkIf (pgUnits != [ ] || bk.sqliteDatabases != [ ] || bk.zfsDatasets != [ ]) (
            lib.getExe backup
          );
        };
      };

      systemd.services.nixos-upgrade-failed = {
        description = "Report a failed nixos-upgrade";
        path = [ pkgs.curl ];
        serviceConfig = {
          Type = "oneshot";
          LoadCredential = [ ntfyCredential ];
        };
        script = ''
          curl -fsS --max-time 20 -H "Title: nixos-upgrade failed on ${host}" -H "Tags: rotating_light" \
            -d "See: journalctl -u nixos-upgrade -b" "$(<"$CREDENTIALS_DIRECTORY/ntfy")"
        '';
      };
    })
  ];
}
