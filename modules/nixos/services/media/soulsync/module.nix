{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.soulsync;
in
{
  options = {
    services.soulsync = {
      enable = lib.mkEnableOption "SoulSync, an Automated Music Discovery and Collection Manager";

      package = lib.mkPackageOption pkgs "soulsync" { };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/soulsync";
        description = "The directory where SoulSync stores its database, config, and logs.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Open ports in the firewall for SoulSync.
          This opens the main UI port (8008) and the OAuth callback ports (8888, 8889).
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8008;
        description = "The main port SoulSync listens on.";
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/run/secrets/soulsync.env";
        description = ''
          File containing environment variables for SoulSync, such as API keys.
          This is the recommended way to supply secrets (e.g., Spotify/Tidal Client IDs) 
          without leaking them into the world-readable Nix store.
        '';
      };

      environment = lib.mkOption {
        type = lib.types.submodule {
          # Allowing strings, bools, and ints here so the mapping function can do its job
          freeformType =
            with lib.types;
            attrsOf (oneOf [
              str
              bool
              int
            ]);
          options = {
            SOULSYNC_LOG_LEVEL = lib.mkOption {
              type = lib.types.enum [
                "DEBUG"
                "INFO"
                "WARNING"
                "ERROR"
                "CRITICAL"
              ];
              default = "INFO";
              description = "The logging level for the SoulSync application.";
            };
            SOULSYNC_SPOTIFY_CALLBACK_PORT = lib.mkOption {
              type = lib.types.port;
              default = 8888;
              description = "Port for the Spotify OAuth callback server.";
            };
            SOULSYNC_TIDAL_CALLBACK_PORT = lib.mkOption {
              type = lib.types.port;
              default = 8889;
              description = "Port for the Tidal OAuth callback server.";
            };
          };
        };
        default = { };
        description = "Additional environment variables to pass to the SoulSync service.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "soulsync";
        description = "User account under which SoulSync runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "soulsync";
        description = "Group under which SoulSync runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-soulsync".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.soulsync = {
      description = "SoulSync Music Manager";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # Merge the module's managed env vars (like dataDir) with the freeform config,
      # then apply the toString/boolean mapping.
      environment =
        lib.mapAttrs (_: v: if builtins.isBool v then (if v then "true" else "false") else toString v)
          (
            cfg.environment
            // {
              SOULSYNC_DATA_DIR = cfg.dataDir;
            }
          );

      path = with pkgs; [ ffmpeg ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/soulsync";
        Restart = "on-failure";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.port
        cfg.environment.SOULSYNC_SPOTIFY_CALLBACK_PORT
        cfg.environment.SOULSYNC_TIDAL_CALLBACK_PORT
      ];
    };

    users.users = lib.mkIf (cfg.user == "soulsync") {
      soulsync = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        description = "SoulSync service user";
      };
    };

    users.groups = lib.mkIf (cfg.group == "soulsync") {
      soulsync = { };
    };
  };
}
