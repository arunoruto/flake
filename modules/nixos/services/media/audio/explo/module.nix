{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.explo;

  envToString = v: if builtins.isBool v then (if v then "true" else "false") else toString v;
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
            OnCalendar = lib.mkOption {
              type = lib.types.str;
              description = "systemd calendar event (e.g. 'Tue 00:15:00').";
            };
            flags = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "CLI flags passed to explo for this schedule.";
            };
          };
        }
      );
      default = { };
      description = "Named schedules for running explo. Each creates a systemd service+timer pair.";
    };
  };

  config = lib.mkIf cfg.enable {
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
              "${pkgs.coreutils}/bin/touch %S/explo/.env"
              "${pkgs.coreutils}/bin/ln -sf ${cfg.package}/share/explo/search_ytmusic.py %S/explo/search_ytmusic.py"
              "${pkgs.coreutils}/bin/ln -sf ${cfg.package}/share/explo/search_ytmusic.py ${cfg.environment.DOWNLOAD_DIR}/search_ytmusic.py"
            ];
            ExecStart = "${lib.getExe cfg.package} --config %S/explo/.env ${schedule.flags}";
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            WorkingDirectory = cfg.environment.DOWNLOAD_DIR;
            ReadWritePaths = [
              cfg.environment.DOWNLOAD_DIR
            ];

            DynamicUser = true;
            StateDirectory = "explo";

            ProtectSystem = "full";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
          };
        };
      }) cfg.schedules
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
      }) cfg.schedules
    );

    users.users.explo = lib.mkIf (cfg.user == "explo") {
      isSystemUser = true;
      group = cfg.group;
      home = "/var/lib/explo";
      createHome = false;
    };

    users.groups = lib.mkIf (cfg.group == "explo") {
      explo = { };
    };
  };
}
