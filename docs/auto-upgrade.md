# Automatic upgrades

Every NixOS host upgrades itself from `github:arunoruto/flake/main` each day,
but never over a change that was deployed by hand and not pushed yet.

## How it works

1. **01:17 UTC — CI** (`.github/workflows/update.yaml`) runs `nix flake update`
   and force-pushes the result to the `update-flake-lock` branch. It then builds
   every host's `system.build.toplevel` in a matrix (`pi` on a native ARM
   runner) and evaluates everything else with `scripts/eval-all.sh`. The run's
   summary page has an `nvd diff` per host. The lock commit is pushed to `main`
   **only if every host built**. Otherwise the run fails and the hosts keep
   running yesterday's `main`.
2. **05:00 local (± 30 min) — each host** runs `nixos-upgrade.service`
   (`modules/nixos/system/upgrade.nix`):
   - **ExecCondition**: the guard (`upgrade-guard.sh`) reads the commit the
     running system was built from (`nixos-version --configuration-revision`)
     and asks GitHub's compare API whether `main` contains it. It goes ahead
     only for `identical` or `behind`. A `-dirty` build, a commit GitHub does
     not know, `ahead`/`diverged`, or an API error **skips** the upgrade
     cleanly and pushes an ntfy notification.
   - **ExecStartPre**: backs up the data that an app migration could change:
     `postgresqlBackup` dumps (Immich), SQLite copies in
     `/var/backup/pre-upgrade/` (Pocket ID, Stump; previous copy kept as
     `.prev`), and ZFS snapshots `<dataset>@pre-upgrade-<time>` (sado's
     `flash/appdata`; the newest 7 are kept). If the backup fails, the upgrade
     does not run.
   - **ExecStart**: `nixos-rebuild switch --refresh --flake github:arunoruto/flake/main#<host>`.
   - **ExecStartPost**: if any package version changed, sends the
     `nvd diff` (old → new system) to ntfy as "<host> upgraded". A new commit
     that only changes the revision stamp stays silent.
   - **OnFailure**: `nixos-upgrade-failed.service` sends an ntfy notification.

Notifications go to the URL in the sops secret `tokens/ntfy/upgrade`
(`https://ntfy.sh/<topic>`). Subscribe to that topic in the ntfy app.

## Deploying by hand

`just deploy …` / `just deploy-tag …` refuse a dirty tree, `git push`, then
run colmena, so the host ends up on a commit `main` has and keeps upgrading.
`just deploy-dirty …` (and `just switch` from a dirty tree) deploys as-is; that
host then skips upgrades, with a notification every day, until it runs a pushed
commit again.

## Why did a host skip?

```sh
journalctl -u nixos-upgrade -b         # the guard logs "skipping upgrade: <reason>"
nixos-version --configuration-revision # what the host is running
systemctl list-timers nixos-upgrade
```

Then push the missing commits and `just deploy --on <host>`. To try the guard
itself: `nix shell nixpkgs#{curl,jq,python3} -c scripts/test-upgrade-guard.sh`.

## Opting out and backing up more

```nix
system.autoUpgrade.enable = false;                        # this host never upgrades itself
system.autoUpgrade.backup.sqliteDatabases = [ "/var/lib/foo/foo.db" ];
system.autoUpgrade.backup.zfsDatasets = [ "tank/appdata" ];
services.postgresqlBackup = { enable = true; databases = [ "foo" ]; };  # dumped too
```

A service module should register its own data, as `pocket-id.nix`,
`immich.nix` and `stump.nix` do.

## Taking a service from nixos-unstable

Internet-facing apps should track upstream releases. The package alone usually
works under the stable module (Immich does this):

```nix
services.immich.package = pkgs.unstable.immich;
```

When the stable module no longer fits the new package, take the module from
unstable too. Look up its path under `nixos/modules/` in the unstable source:

```nix
{ inputs, pkgs, ... }:
{
  disabledModules = [ "services/security/pocket-id.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/security/pocket-id.nix" ];
  services.pocket-id.package = pkgs.unstable.pocket-id;
}
```

Check with `nix eval .#nixosConfigurations.<host>.config.services.<svc>.package.version`.

## Rolling back

```sh
sudo nixos-rebuild switch --rollback       # previous generation (or pick one in the boot menu)
```

A rollback restores code, not data an app has already migrated. Restore that
from the pre-upgrade backup first:

- ZFS: `zfs rollback flash/appdata@pre-upgrade-<time>` (`-r` if newer snapshots exist)
- SQLite: stop the service, copy `/var/backup/pre-upgrade/<db>` back over the database
- Postgres: `zcat /var/backup/postgresql/immich.sql.gz | sudo -u postgres psql immich` (on a recreated, empty database)

Rolling back is a hand-deployed change, so the next upgrade moves the host
forward again. To stay on the old version, revert the commit on `main`.
