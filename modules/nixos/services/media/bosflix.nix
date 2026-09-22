{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.services.bosflix = {
    enable = lib.mkEnableOption "Enable bosflix services";

    drivePath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/hdd";
      description = "The path to the HDD";
    };
  };

  config =
    let
      cfg = config.services.bosflix;
      # completedPath = "/media/86336459-5d8c-448e-93c3-f3e17c00d3b9" + "/complete";
      completedPath = builtins.toString (cfg.drivePath + "/complete");
      drivePath = builtins.toString cfg.drivePath;
      incompletedPath = builtins.toString (cfg.drivePath + "/incomplete");
      mediaGroup = "media";
      # The per-consumer folders that are synced out to the *arr hosts; see
      # modules/nixos/services/media/syncthing/folders.nix.
      syncedFolders = [
        "mirza-music"
        "mirza-shows"
        "mirza-movies"
      ];
      # Everything on the drive is shared between the downloaders, syncthing and
      # the *arrs, so it all gets the same setgid + group-writable treatment.
      sharedPaths = [
        completedPath
        incompletedPath
      ]
      ++ map (name: "${completedPath}/${name}") syncedFolders;
    in
    lib.mkIf cfg.enable {
      services = {
        prowlarr = {
          enable = true;
          # package = pkgs.unstable.prowlarr;
          # settings = {
          #   server = {
          #     urlbase = "/prowlarr";
          #     AuthenticationMethod = "Forms";
          #     AuthenticationRequired = "DisabledForLocalAddresses";
          #   };
          # };
        };

        flaresolverr = {
          enable = true;
          # package = pkgs.nur.repos.xddxdd.flaresolverr-21hsmw;
          # package = pkgs.unstable.flaresolverr;
          package = pkgs.flaresolverr;
        };

        syncthing = {
          enable = true;

          settings = {
            devices = {
              # lil-nas-x = {
              #   addresses = [
              #     "dynamic"
              #     "tcp://lil-nas-x"
              #     "tcp://lil-nas-x:22000"
              #     "quic://lil-nas-x:22000"
              #   ];
              #   id = "ARZDFKU-CFAXQEM-ZTBEVH6-DGU7E55-JNLRTVM-VKG7JW5-D6B25X3-IRPISQH";
              # };
              kuchiki = {
                addresses = [
                  "dynamic"
                  "tcp://kuchiki"
                  "tcp://kuchiki:22000"
                  "quic://kuchiki:22000"
                ];
                id = "C4TO46K-P5LXFD6-NULLWDR-A5MYGJ2-EQDBNOC-CZHYJNJ-33DJHWA-SPQ6RQ7";
              };
            };
          };
        };

        deluge = {
          enable = false;
          web.enable = true;
          # declarative = true;
          config = {
            # download_location = "${cfg.drivePath}/incomplete";
            download_location = incompletedPath;
            move_completed = true;
            move_completed_path = completedPath;

            enabled_plugins = [ "Label" ];
          };
        };

        # transmission = {
        #   enable = true;
        # };
      };

      systemd =
        let
          cfg = config.services.sabnzbd;
          syncthingCfg = config.services.syncthing;
        in
        {
          services.sabnzbd.serviceConfig.ExecStart =
            # lib.mkForce "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${"/var/lib/${cfg.stateDir}/sabnzbd.ini"} --inet_exposure 5 --disable-file-log --console";
            lib.mkForce
              "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${"/var/lib/${cfg.stateDir}/sabnzbd.ini"} -s 0.0.0.0:8082 --inet_exposure 5";

          # The drive is an autofs mount (`x-systemd.automount`) and
          # systemd-tmpfiles refuses to traverse autofs mount points: at boot it
          # logs "Detected autofs mount point '<drivePath>' ... Skipping" for
          # every rule below it, so these directories were never actually created
          # or fixed up. They ended up root-umask 2755, which locks out the rest
          # of the `media` group — sabnzbd above all. Do it from a unit that
          # pulls the mount in itself instead.
          services.bosflix-dirs = {
            description = "Create bosflix download directories";
            wantedBy = [ "multi-user.target" ];
            before =
              lib.optional config.services.sabnzbd.enable "sabnzbd.service"
              ++ lib.optional config.services.qbittorrent.enable "qbittorrent.service"
              ++ lib.optional config.services.syncthing.enable "syncthing.service";
            unitConfig.RequiresMountsFor = [
              completedPath
              incompletedPath
            ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            path = [ pkgs.coreutils ];
            # setgid so anything created underneath inherits the `media` group,
            # group-writable so every member of that group (sabnzbd, qbittorrent,
            # syncthing, the *arrs) can write into the shared folders. Those
            # services all run with UMask=0002, which keeps the group-write bit
            # on the directories they create in turn.
            script = ''
              install -d -o ${config.users.primaryUser} -g ${mediaGroup} -m 0775 ${lib.escapeShellArg drivePath}
              install -d -o root -g ${mediaGroup} -m 2775 ${lib.escapeShellArgs sharedPaths}
            ''
            + lib.optionalString config.services.syncthing.enable ''
              install -d -o ${syncthingCfg.user} -g ${syncthingCfg.group} -m 0755 ${lib.escapeShellArg "${completedPath}/.stfolder"}
            '';
          };

          tmpfiles.settings = {
            "sabnzbd" = {
              "/var/lib/sabnzbd".Z = {
                mode = "0755";
                inherit (cfg) user;
                inherit (cfg) group;
              };
              # "/var/lib/sabnzbd/logs".Z = {
              #   mode = "0755";
              #   user = cfg.user;
              #   group = cfg.group;
              # };
              # "/var/lib/sabnzbd/Downloads".Z = {
              #   mode = "0755";
              #   user = cfg.user;
              #   group = cfg.group;
              # };
            };
          };
        };

      # lib.mkForce "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${"/var/lib/${cfg.stateDir}/sabnzbd.ini"} --inet_exposure 5 --console";
      # lib.mkForce "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${"/var/lib/${cfg.stateDir}/sabnzbd.ini"} --inet_exposure 5";

      # nixpkgs.config.permittedInsecurePackages = [
      #   "aspnetcore-runtime-6.0.36"
      #   "aspnetcore-runtime-wrapped-6.0.36"
      #   "dotnet-runtime-6.0.36"
      #   "dotnet-runtime-wrapped-6.0.36"
      #   "dotnet-sdk-6.0.428"
      #   "dotnet-sdk-wrapped-6.0.428"
      # ];

      # environment.systemPackages = with pkgs.unstable; [ qbittorrent ];
    };
}
