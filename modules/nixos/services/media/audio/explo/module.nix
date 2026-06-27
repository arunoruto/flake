{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.explo;

  envToString = v: if builtins.isBool v then (if v then "true" else "false") else toString v;

  configDir = "/var/lib/explo";
  envPath = "${configDir}/.env";
  webuiDataDir = "${configDir}/webui";
in
{
  options.services.explo = {
    enable = lib.mkEnableOption "Explo - Spotify's Discover Weekly for self-hosted music systems";

    package = lib.mkPackageOption pkgs "explo" { };

    environment = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf str;
        options = {
          DISCOVERY_SERVICE = lib.mkOption {
            type = lib.types.enum [ "listenbrainz" ];
            default = "listenbrainz";
            description = "Service which recommends songs.";
          };
          LISTENBRAINZ_USER = lib.mkOption {
            type = lib.types.str;
            description = "Your ListenBrainz username.";
          };
          LISTENBRAINZ_DISCOVERY = lib.mkOption {
            type = lib.types.enum [
              "playlist"
              "api"
            ];
            default = "playlist";
            description = "ListenBrainz discovery method.";
          };
          EXPLO_SYSTEM = lib.mkOption {
            type = lib.types.enum [
              "emby"
              "jellyfin"
              "mpd"
              "plex"
              "subsonic"
            ];
            description = "Music system to use.";
          };
          SYSTEM_URL = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Base URL of media server. Not required for MPD.";
          };
          SYSTEM_USERNAME = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Username for system authentication. Not required for MPD.";
          };
          LIBRARY_NAME = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Name of the music library. Required for Emby, Jellyfin, Plex.";
          };
          PLAYLIST_DIR = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Filesystem path where .m3u playlists should be written. Required for MPD.";
          };
          DOWNLOAD_DIR = lib.mkOption {
            type = lib.types.path;
            default = "/var/lib/explo";
            description = "Directory to store downloaded tracks.";
          };
          DOWNLOAD_SERVICES = lib.mkOption {
            type = lib.types.str;
            default = "youtube";
            description = "Comma-separated list (no spaces) of download services in priority order.";
          };
          TRACK_EXTENSION = lib.mkOption {
            type = lib.types.str;
            default = "opus";
            description = "Custom file extension for tracks.";
          };
          LOG_LEVEL = lib.mkOption {
            type = lib.types.enum [
              "DEBUG"
              "INFO"
              "WARN"
              "ERROR"
            ];
            default = "INFO";
            description = "Log detail level.";
          };
          SLEEP = lib.mkOption {
            type = lib.types.int;
            default = 2;
            description = "Minutes to sleep between library scans.";
          };
          CLIENT_HTTP_TIMEOUT = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = "Custom HTTP timeout for music servers (in seconds).";
          };
          SINGLE_ARTIST = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Merge featured artists into title.";
          };
          PLAYLISTNAME_FORMAT = lib.mkOption {
            type = lib.types.enum [
              "week"
              "date"
            ];
            default = "week";
            description = "Playlist name format.";
          };
          USE_SUBDIRECTORY = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Download tracks to a subdirectory named after the playlist.";
          };
          KEEP_PERMISSIONS = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Keep original file permissions when moving files.";
          };
          FILTER_LIST = lib.mkOption {
            type = lib.types.str;
            default = "live,remix,instrumental,extended,clean,acapella";
            description = "Comma-separated blacklist keywords for YouTube/slskd.";
          };
          COOKIES_PATH = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to optional cookies file.";
          };
          PUBLIC_PLAYLIST = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Mark playlist as public (Subsonic).";
          };
          ADMIN_SYSTEM_USERNAME = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Optional admin username for library scan triggering (Navidrome/Subsonic).";
          };
          FFMPEG_PATH = lib.mkOption {
            type = lib.types.path;
            default = lib.getExe pkgs.ffmpeg;
            description = "ffmpeg binary path.";
          };
          YTDLP_PATH = lib.mkOption {
            type = lib.types.path;
            default = lib.getExe pkgs.yt-dlp;
            description = "yt-dlp binary path.";
          };
        };
      };
      default = { };
      description = ''
        Explo configuration passed as environment variables to the process.
        This field ends up in the systemd unit (Nix store), so secrets should go in `environmentFile`.
        See https://github.com/LumePart/Explo/wiki/3.-Configuration-Parameters
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to add to the service PATH (e.g. python3 with ytmusicapi).";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to an environment file containing secrets, loaded via systemd EnvironmentFile.
        Use sops-nix templates to keep secrets out of the Nix store:
        e.g. `config.sops.templates."explo".path`.
        Useful for API_KEY, SYSTEM_PASSWORD, YOUTUBE_API_KEY, ADMIN_SYSTEM_PASSWORD,
        SLSKD_API_KEY, DISCORD_BOT_TOKEN, MATRIX_ACCESSTOKEN, etc.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "explo";
      description = "User the explo service runs as.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "explo";
      description = "Group the explo service runs as.";
    };

    schedules = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "this Explo schedule";
            OnCalendar = lib.mkOption {
              type = lib.types.str;
              description = "systemd calendar event (e.g. 'Tue 00:15:00').";
            };
            flags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "CLI flags passed to explo for this schedule.";
            };
          };
        }
      );
      default = { };
      description = "Named schedules for running explo. Each creates a systemd service+timer pair.";
    };

    webui = {
      enable = lib.mkEnableOption "Explo web configuration UI" // {
        default = true;
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = ":7288";
        description = "Listen address for the web UI (host:port).";
      };

      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Username for web UI authentication (UI_USERNAME).";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to file containing web UI password (UI_PASSWORD). Loaded via systemd LoadCredential.";
      };

      cacheMb = lib.mkOption {
        type = lib.types.int;
        default = 500;
        description = "Maximum cover art cache size in MB.";
      };

      syncSchedule = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          systemd calendar interval for syncing *_SCHEDULE entries from the .env file.
          When set, creates a timer that reads schedules written by the web UI and
          executes matching playlist runs. Matches Docker's cron behavior.
          Set to e.g. "*:00/15" for every 15 minutes.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${configDir} 0700 ${cfg.user} ${cfg.group} -"
      "d ${webuiDataDir} 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (name: schedule: {
        "explo-${name}" = {
          description = "Explo music discovery (${name})";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          path = cfg.extraPackages;

          environment = lib.mapAttrs (_: envToString) cfg.environment;

          serviceConfig = {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            ExecStartPre = [
              "+${pkgs.coreutils}/bin/mkdir -p ${configDir}"
              "+${pkgs.coreutils}/bin/chown ${cfg.user}:${cfg.group} ${configDir}"
              "${pkgs.coreutils}/bin/touch ${envPath}"
              "+${pkgs.coreutils}/bin/chown ${cfg.user}:${cfg.group} ${envPath}"
              "${pkgs.coreutils}/bin/ln -sf ${cfg.package}/share/explo/search_ytmusic.py ${configDir}/search_ytmusic.py"
              "!${pkgs.coreutils}/bin/ln -sf ${cfg.package}/share/explo/search_ytmusic.py ${cfg.environment.DOWNLOAD_DIR}/search_ytmusic.py"
            ];
            ExecStart = lib.escapeShellArgs (
              [
                "${lib.getExe cfg.package}"
                "--config"
                envPath
              ]
              ++ schedule.flags
            );
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            WorkingDirectory = cfg.environment.DOWNLOAD_DIR;
            ReadWritePaths = [
              cfg.environment.DOWNLOAD_DIR
              configDir
            ];

            ProtectSystem = "full";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
          };
        };
      }) (lib.filterAttrs (_: s: s.enable) cfg.schedules)
      ++ lib.optional cfg.webui.enable {
        "explo-webui" = {
          description = "Explo web configuration UI";
          after = [ "network.target" ];
          wants = [ "network.target" ];

          path = cfg.extraPackages;

          environment =
            lib.mapAttrs (_: envToString) cfg.environment
            // {
              WEB_UI = "true";
              WEB_ADDR = cfg.webui.address;
              WEB_ENV_PATH = envPath;
              WEB_DATA_PATH = webuiDataDir;
              WEB_CACHE_MB = toString cfg.webui.cacheMb;
            }
            // lib.optionalAttrs (cfg.webui.username != null) {
              UI_USERNAME = cfg.webui.username;
            };

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            ExecStart = "${lib.getExe cfg.package}";
            ExecStartPre = [
              "+${pkgs.coreutils}/bin/mkdir -p ${configDir} ${webuiDataDir}"
              "+${pkgs.coreutils}/bin/chown ${cfg.user}:${cfg.group} ${configDir} ${webuiDataDir}"
              "${pkgs.coreutils}/bin/touch ${envPath}"
              "+${pkgs.coreutils}/bin/chown ${cfg.user}:${cfg.group} ${envPath}"
            ];
            LoadCredential = lib.mkIf (cfg.webui.passwordFile != null) "UI_PASSWORD:${cfg.webui.passwordFile}";
            ImportCredential = lib.mkIf (cfg.webui.passwordFile != null) "UI_PASSWORD";
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            WorkingDirectory = webuiDataDir;
            ReadWritePaths = [
              configDir
              webuiDataDir
            ];

            ProtectSystem = "full";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
          };
        };
      }
      ++ lib.optional (cfg.webui.syncSchedule != null) {
        "explo-cron" = {
          description = "Explo cron-style scheduler from web UI .env";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          path = cfg.extraPackages;

          environment = {
            WEB_ENV_PATH = envPath;
            EXPLO_BIN = lib.getExe cfg.package;
          };

          script = ''
                        ${lib.getExe pkgs.python3} -c '
            import os, json, sys, subprocess
            from datetime import datetime, timedelta

            now = datetime.now()
            env_path = os.environ["WEB_ENV_PATH"]
            explo_bin = os.environ["EXPLO_BIN"]
            state_file = os.path.join(os.environ.get("RUNTIME_DIRECTORY", "/tmp"), "explo-cron-state.json")
            lookback_max = timedelta(hours=24)

            last_check = now - lookback_max
            try:
                with open(state_file) as f:
                    last_check = datetime.fromisoformat(json.load(f)["last_check"])
            except Exception:
                pass

            env_vars = {}
            try:
                with open(env_path) as f:
                    for line in f:
                        line = line.strip()
                        if not line or line.startswith("#"):
                            continue
                        if "=" not in line:
                            continue
                        k, v = line.split("=", 1)
                        env_vars[k.strip()] = v.strip()
            except FileNotFoundError:
                sys.exit(0)

            def cron_dow(dt):
                return dt.isoweekday() % 7

            def cron_match(expr, dt):
                parts = expr.split()
                if len(parts) != 5:
                    return False
                patterns = [
                    (parts[0], str(dt.minute)),
                    (parts[1], str(dt.hour)),
                    (parts[2], str(dt.day)),
                    (parts[3], str(dt.month)),
                    (parts[4], str(cron_dow(dt))),
                ]
                for pattern, value in patterns:
                    if pattern == "*":
                        continue
                    if pattern != value:
                        return False
                return True

            current = last_check.replace(second=0, microsecond=0) + timedelta(minutes=1)
            run_count = 0
            while current <= now:
                for key, val in env_vars.items():
                    if not key.endswith("_SCHEDULE") or not val:
                        continue
                    job = key[:-9]
                    flags = env_vars.get(f"{job}_FLAGS", "")
                    if cron_match(val, current):
                        cmd = [explo_bin, "--config", env_path]
                        if flags:
                            cmd.extend(flags.split())
                        print(f"[explo-cron] {current:%Y-%m-%d %H:%M} — running {job}", file=sys.stderr)
                        subprocess.run(cmd)
                        run_count += 1
                current += timedelta(minutes=1)

            if run_count:
                print(f"[explo-cron] executed {run_count} job(s)", file=sys.stderr)

            os.makedirs(os.path.dirname(state_file), exist_ok=True)
            with open(state_file, "w") as f:
                json.dump({"last_check": now.isoformat()}, f)
            '
          '';

          serviceConfig = {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            ReadWritePaths = [ configDir ];

            RuntimeDirectory = "explo-cron";
            ProtectSystem = "full";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
          };
        };
      }
    );

    systemd.timers = lib.mkMerge (
      lib.mapAttrsToList (name: schedule: {
        "explo-${name}" = {
          description = "Timer for Explo music discovery (${name})";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = schedule.OnCalendar;
            Persistent = true;
          };
        };
      }) (lib.filterAttrs (_: s: s.enable) cfg.schedules)
      ++ lib.optional (cfg.webui.syncSchedule != null) {
        "explo-cron" = {
          description = "Timer for Explo web UI .env cron scheduler";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.webui.syncSchedule;
            Persistent = true;
          };
        };
      }
    );

    users.users.explo = lib.mkIf (cfg.user == "explo") {
      isSystemUser = true;
      group = cfg.group;
      home = configDir;
      createHome = true;
    };

    users.groups = lib.mkIf (cfg.group == "explo") {
      explo = { };
    };
  };
}
