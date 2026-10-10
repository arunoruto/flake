{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.retrom;
  igdbSecret = name: "services/retrom/igdb-${name}";
in
{
  # Retrom's own module: services.retrom (server) and programs.retrom (desktop
  # client). It defaults both packages to the flake's builds, made against its
  # own nixpkgs pin -- the only builds retrom.cachix.org can hold.
  imports = [ inputs.retrom.nixosModules.retrom ];

  options.services.retrom.igdb.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Fetch metadata from IGDB, with the Twitch application credentials read
      from sops (`services/retrom/igdb-client-id` and
      `services/retrom/igdb-client-secret`).

      Retrom only takes them from its config file, and upstream renders
      `settings` into the world-readable Nix store. With this on, the whole
      config is rendered by a sops template instead. Either way the file is
      read-only to retrom, so changing server settings from the client UI
      fails: they belong in `settings`.
    '';
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.retrom = {
          dataDir = lib.mkDefault "${config.services.media.dataDir}/retrom";
          # Built without the embedded_db feature, so it needs a real server.
          enableDatabase = lib.mkDefault true;
          # Retrom has no authentication (multi-user auth is still on its
          # roadmap): whoever reaches the port can browse, download and
          # reconfigure the library. br0 and tailscale0 are trusted interfaces
          # on our hosts, so the LAN and the tailnet get in without this.
          openFirewall = lib.mkDefault false;
        };

        users.users.${cfg.user}.extraGroups = lib.optionals (config.users.groups ? "media") [
          config.users.groups.media.name
        ];

        systemd.services.retrom = {
          # Upstream only orders itself after the database; without this a
          # failed postgres leaves retrom crash-looping into its start limit.
          requires = lib.optional cfg.enableDatabase "postgresql.target";
          # dataDir and the libraries live on datasets that may mount after
          # activation; scanning a bare mountpoint would empty the library.
          unitConfig.RequiresMountsFor = [
            cfg.dataDir
          ]
          ++ map (dir: dir.path) (cfg.settings.contentDirectories or [ ]);
        };

        # Also in flake.nix's nixConfig; this keeps it for builds that do not go
        # through the flake, e.g. a colmena deploy building on this host.
        nix.settings = {
          extra-substituters = [ "https://retrom.cachix.org" ];
          extra-trusted-public-keys = [
            "retrom.cachix.org-1:6fjezFeBSDzHkUvpyLMe58wfi99V4RO8M5Iod4sMxFE="
          ];
        };
      }

      (lib.mkIf cfg.igdb.enable {
        sops.secrets = {
          ${igdbSecret "client-id"} = { };
          ${igdbSecret "client-secret"} = { };
        };

        # Mirrors what upstream writes for `settings`, plus the credentials.
        sops.templates."retrom.json" = {
          owner = cfg.user;
          restartUnits = [ "retrom.service" ];
          content = builtins.toJSON (
            cfg.settings
            // {
              connection = {
                inherit (cfg) port;
                dbUrl = if cfg.dbUrl == null then "postgres:///retrom?host=/var/run/postgresql" else cfg.dbUrl;
              };
              igdb = {
                clientId = config.sops.placeholder.${igdbSecret "client-id"};
                clientSecret = config.sops.placeholder.${igdbSecret "client-secret"};
              };
            }
          );
        };

        services.retrom.configFile = config.sops.templates."retrom.json".path;
      })
    ]
  );
}
