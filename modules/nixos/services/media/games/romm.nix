{
  lib,
  config,
  ...
}:
let
  cfg = config.services.romm;
  # The Twitch app credentials retrom uses too; one IGDB app serves both.
  igdbSecret = name: "services/retrom/igdb-${name}";
  libraryPath = "${cfg.dataDir}/library";
  units = [
    "romm"
    "romm-worker"
    "romm-scheduler"
  ]
  ++ lib.optional cfg.watcher.enable "romm-watcher";
  httpPort = config.services.nginx.defaultHTTPListenPort;
in
{
  options.services.romm = {
    library = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/mnt/flash/games";
      description = ''
        Existing collection to bind-mount at `dataDir/library`, the only place
        upstream reads the library from. RomM expects `roms/<platform>/` and
        `bios/<platform>/` inside it; ES-DE's system folder names are
        recognised as platforms.
      '';
    };

    igdb.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Fetch metadata from IGDB, with the Twitch application credentials read
        from sops (`services/retrom/igdb-client-id` and
        `services/retrom/igdb-client-secret`).
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.romm = {
          dataDir = lib.mkDefault "${config.services.media.dataDir}/romm";
          # Upstream's 8080 is where nginx listens next to Traefik; the backend
          # is only reached through nginx on loopback anyway.
          port = lib.mkDefault 8000;
          nginx.virtualHost = lib.mkDefault config.networking.hostName;
          # Upstream derives this from the virtual host alone and misses a
          # non-default port, which ../../network/nginx.nix sets next to
          # Traefik. RomM builds invite and password-reset links from it.
          extraEnvironment.ROMM_BASE_URL = lib.mkIf cfg.nginx.enable (
            lib.mkDefault "http://${cfg.nginx.virtualHost}${
              lib.optionalString (httpPort != 80) ":${toString httpPort}"
            }"
          );
        };

        users.users.${cfg.user}.extraGroups = lib.optionals (config.users.groups ? "media") [
          config.users.groups.media.name
        ];

        systemd.services = lib.genAttrs units (_: {
          # Uploads and renames land in the shared library, which the media
          # group (samba, syncthing) has to be able to write too.
          serviceConfig.UMask = "0002";
          # The data dir and the library may be datasets that mount after
          # activation; a scan of a bare mountpoint would empty the library.
          unitConfig.RequiresMountsFor = [ libraryPath ];
        });
      }

      (lib.mkIf (cfg.library != null) {
        fileSystems.${libraryPath} = {
          device = cfg.library;
          fsType = "none";
          options = [ "bind" ];
          depends = [ cfg.library ];
        };
        # Upstream's rule would chown the mountpoint to romm:romm 0750 -- and,
        # through the bind mount, the collection itself, locking out everyone
        # else who shares it. The collection keeps its own ownership.
        systemd.tmpfiles.settings."10-romm".${libraryPath} = lib.mkForce { };
      })

      (lib.mkIf cfg.igdb.enable {
        sops.secrets = {
          ${igdbSecret "client-id"} = { };
          ${igdbSecret "client-secret"} = { };
        };
        sops.templates."romm.env" = {
          restartUnits = map (unit: "${unit}.service") units;
          content = ''
            IGDB_CLIENT_ID=${config.sops.placeholder.${igdbSecret "client-id"}}
            IGDB_CLIENT_SECRET=${config.sops.placeholder.${igdbSecret "client-secret"}}
          '';
        };
        services.romm.environmentFile = config.sops.templates."romm.env".path;
      })
    ]
  );
}
