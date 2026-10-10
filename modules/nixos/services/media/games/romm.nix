{
  lib,
  config,
  ...
}:
let
  cfg = config.services.romm;
  libraryPath = "${cfg.dataDir}/library";
  units = [
    "romm"
    "romm-worker"
    "romm-scheduler"
  ]
  ++ lib.optional cfg.watcher.enable "romm-watcher";
  httpPort = config.services.nginx.defaultHTTPListenPort;
  localUrl = "http://${cfg.nginx.virtualHost}${
    lib.optionalString (httpPort != 80) ":${toString httpPort}"
  }";
  baseUrl = if cfg.publicHost != null then "https://${cfg.publicHost}" else localUrl;

  # Environment variable -> sops secret, rendered into one env file.
  envSecrets =
    lib.optionalAttrs cfg.igdb.enable {
      # The Twitch app credentials retrom uses too; one IGDB app serves both.
      IGDB_CLIENT_ID = "services/retrom/igdb-client-id";
      IGDB_CLIENT_SECRET = "services/retrom/igdb-client-secret";
    }
    // lib.optionalAttrs cfg.oidc.enable {
      OIDC_CLIENT_ID = "services/romm/client-id";
      OIDC_CLIENT_SECRET = "services/romm/client-secret";
    };
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

    publicHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "rom.arnaut.me";
      description = ''
        Public hostname, routed to the nginx virtual host through this host's
        cloudflared tunnel, which also terminates TLS. Its DNS record has to
        point at the tunnel. Becomes the base URL RomM builds links from.
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

    oidc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Sign in through Pocket ID only: no setup wizard, no local accounts.
          Users are created on their first login, and members of
          {option}`services.romm.oidc.adminGroup` become admins. The client
          credentials are read from sops (`services/romm/client-id` and
          `services/romm/client-secret`); the client's callback URL is
          `https://<publicHost>/api/oauth/openid`.
        '';
      };
      issuer = lib.mkOption {
        type = lib.types.str;
        default = "https://id.arnaut.me";
        description = "Root URL of the Pocket ID instance.";
      };
      adminGroup = lib.mkOption {
        type = lib.types.str;
        # Pocket ID's group for the people who get access to everything.
        default = "arnaut";
        description = ''
          Pocket ID group whose members are RomM admins, by the group's Name
          (not its Friendly Name). Once roles come from groups, RomM turns away
          anyone in none of the mapped groups.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.oidc.enable -> cfg.publicHost != null;
            message = "services.romm.oidc needs services.romm.publicHost: Pocket ID only redirects back to an https URL.";
          }
        ];

        services.romm = {
          dataDir = lib.mkDefault "${config.services.media.dataDir}/romm";
          # Upstream's 8080 is where nginx listens next to Traefik; the backend
          # is only reached through nginx on loopback anyway.
          port = lib.mkDefault 8000;
          nginx.virtualHost = lib.mkDefault config.networking.hostName;
          # Upstream derives this from the virtual host alone and misses both
          # a public hostname and a non-default port, which
          # ../../network/nginx.nix sets next to Traefik. RomM builds invite,
          # password-reset and OIDC links from it.
          extraEnvironment.ROMM_BASE_URL = lib.mkIf cfg.nginx.enable (lib.mkDefault baseUrl);
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

      (lib.mkIf (cfg.publicHost != null) {
        services.nginx.virtualHosts.${cfg.nginx.virtualHost}.serverAliases = [ cfg.publicHost ];
        services.cloudflared.tunnels.${config.networking.hostName}.ingress =
          lib.mkIf config.services.cloudflared.enable
            [
              {
                hostname = cfg.publicHost;
                service = "http://localhost:${toString httpPort}";
              }
            ];
      })

      (lib.mkIf cfg.oidc.enable {
        services.romm.extraEnvironment = {
          OIDC_ENABLED = "true";
          OIDC_PROVIDER = "pocket-id";
          OIDC_SERVER_APPLICATION_URL = cfg.oidc.issuer;
          OIDC_REDIRECT_URI = "${baseUrl}/api/oauth/openid";
          # Also requested as a scope, which is what makes Pocket ID send it.
          OIDC_CLAIM_ROLES = "groups";
          OIDC_ROLE_ADMIN = cfg.oidc.adminGroup;
          # Straight to the passkey prompt instead of RomM's login form.
          OIDC_AUTOLOGIN = "true";
          # The wizard only creates the first local admin, which Pocket ID
          # replaces.
          DISABLE_SETUP_WIZARD = "true";
        };
      })

      (lib.mkIf (envSecrets != { }) {
        sops.secrets = lib.genAttrs (lib.attrValues envSecrets) (_: { });
        sops.templates."romm.env" = {
          restartUnits = map (unit: "${unit}.service") units;
          content = lib.concatStrings (
            lib.mapAttrsToList (var: secret: "${var}=${config.sops.placeholder.${secret}}\n") envSecrets
          );
        };
        services.romm.environmentFile = config.sops.templates."romm.env".path;
      })
    ]
  );
}
