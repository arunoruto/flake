{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./module.nix ];

  config = lib.mkIf config.services.explo.enable {
    services.explo = {
      package = lib.mkDefault pkgs.explo;
      extraPackages = [
        (pkgs.python3.withPackages (ps: [ ps.ytmusicapi ]))
      ];
      environment = {
        LISTENBRAINZ_USER = "arunoruto";
        LISTENBRAINZ_DISCOVERY = "playlist";
        # LISTENBRAINZ_DISCOVERY = "api";
        # Music System Configuration
        EXPLO_SYSTEM = "plex";
        SYSTEM_URL = "http://127.0.0.1:32400";
        LIBRARY_NAME = "Music";
        # Downloader Configuration
        DOWNLOAD_DIR = "/mnt/flash/music/discover";
        USE_SUBDIRECTORY = true;
        DOWNLOAD_SERVICES = "youtube";
        KEEP_PERMISSIONS = true;
        # Youtube Specific Variables
        TRACK_EXTENSION = "mp3";
      };
      environmentFile = config.sops.templates."explo.env".path;
      schedules.weekly-exploration = lib.mkDefault {
        enable = true;
        OnCalendar = "Wed 08:00:00";
        flags = [ ];
      };
      schedules.weekly-jams = lib.mkDefault {
        enable = true;
        OnCalendar = "Wed 08:00:00";
        flags = [
          "--playlist"
          "weekly-jams"
          # "--download-mode=skip"
        ];
      };
      schedules.daily-jams = lib.mkDefault {
        enable = true;
        OnCalendar = "*-*-* 06:00:00";
        flags = [
          "--playlist"
          "daily-jams"
          # "--download-mode=skip"
        ];
      };
    };

    sops = {
      secrets = {
        # "services/explo/youtube-api-key" = { };
        # "services/explo/system-password" = { };
        # "services/explo/api-key" = { };
        # "services/explo/admin-system-password" = { };
        "tokens/plex" = { };
        "tokens/youtube" = { };
      };
      templates."explo.env" = {
        content = ''
          API_KEY=${config.sops.placeholder."tokens/plex"}
          YOUTUBE_API_KEY=${config.sops.placeholder."tokens/youtube"}
        '';
        #   YOUTUBE_API_KEY=${config.sops.placeholder."services/explo/youtube-api-key"}
        #   SYSTEM_PASSWORD=${config.sops.placeholder."services/explo/system-password"}
        #   API_KEY=${config.sops.placeholder."services/explo/api-key"}
        #   ADMIN_SYSTEM_PASSWORD=${config.sops.placeholder."services/explo/admin-system-password"}
        # '';
      };
    };

    users.users.explo.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];

  };
}
