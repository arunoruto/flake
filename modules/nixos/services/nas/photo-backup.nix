# Off-site copies of immich's library (originals plus its nightly database
# dumps in backups/). sado snapshots flash/photos with sanoid; the NAS hosts
# pull it nightly with syncoid and keep their own, longer history.
#
# Pulling keeps the copies out of sado's reach: its syncoid-pull account may
# only `zfs send`, so a compromised sado can neither delete nor overwrite them.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.backups.photos;
  sourceHost = "sado";
  sourceDataset = "flash/photos";
  sourceUser = "syncoid-pull";
  targetDataset = "storage/personal/backup/sado-photos";
  # Tailscale SSH answers on :22 over the tailnet and ignores authorized_keys,
  # so the pulls go to a second sshd port that admits only this account.
  sshPort = 2222;
in
{
  options.backups.photos = {
    source.enable = lib.mkEnableOption "snapshotting immich's library and serving it to the backup pulls";
    target.enable = lib.mkEnableOption "pulling ${sourceHost}'s immich library into ${targetDataset}";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.source.enable {
      services.sanoid = {
        enable = true;
        datasets.${sourceDataset} = {
          autosnap = true;
          autoprune = true;
          hourly = 48;
          daily = 30;
          monthly = 12;
        };
      };

      users.users.${sourceUser} = {
        isSystemUser = true;
        group = sourceUser;
        # syncoid runs zfs and shell pipelines over ssh.
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          ''restrict,from="100.64.0.0/10,fd7a:115c:a1e0::/48" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgc7giMXACM+TSCuzCZKmxSZG5tMVDFSFWwKEbWd7VW syncoid-pull''
        ];
      };
      users.groups.${sourceUser} = { };

      services.openssh = {
        ports = [
          22
          sshPort
        ];
        extraConfig = ''
          Match LocalPort ${toString sshPort}
            AllowUsers ${sourceUser}
            PasswordAuthentication no
            KbdInteractiveAuthentication no
        '';
      };

      # send only: the pulls reuse sanoid's snapshots (--no-sync-snap)
      # and never create or destroy anything here.
      systemd.services.zfs-allow-syncoid-pull = {
        wantedBy = [ "multi-user.target" ];
        after = [ "zfs.target" ];
        path = [ config.boot.zfs.package ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = "zfs allow ${sourceUser} send ${sourceDataset}";
      };
    })

    (lib.mkIf cfg.target.enable {
      sops.secrets."syncoid/pull-key".owner = config.services.syncoid.user;

      programs.ssh.knownHosts.${sourceHost} = {
        hostNames = [ "[${sourceHost}]:${toString sshPort}" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFMG2u883DloAYpbwTXAdbAQxpxwInO8XGxjIy45jEQ";
      };

      services.syncoid = {
        enable = true;
        interval = "*-*-* 03:30";
        sshKey = config.sops.secrets."syncoid/pull-key".path;
        commands.sado-photos = {
          source = "${sourceUser}@${sourceHost}:${sourceDataset}";
          target = targetDataset;
          extraArgs = [
            "--no-sync-snap"
            "--sshport=${toString sshPort}"
          ];
          # Received unmounted; the parent's mountpoint=legacy keeps it that way.
          recvOptions = "u";
        };
      };

      # Prune only, with a longer memory than sado: losing every snapshot there
      # still leaves months of history here.
      services.sanoid = {
        enable = true;
        datasets.${targetDataset} = {
          autosnap = false;
          autoprune = true;
          hourly = 24;
          daily = 90;
          monthly = 24;
        };
      };
    })
  ];
}
