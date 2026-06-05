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
        LISTENBRAINZ_DISCOVERY = "api";
        EXPLO_SYSTEM = "plex";
        SYSTEM_URL = "http://127.0.0.1:32400";
        LIBRARY_NAME = "Music";
        DOWNLOAD_DIR = "/mnt/flash/music";
      };
      environmentFile = config.sops.templates."explo.env".path;
      schedules.weekly-exploration = lib.mkDefault {
        OnCalendar = "Tue 00:15:00";
        flags = "";
      };
    };

    sops = {
      secrets = {
        # "services/explo/youtube-api-key" = { };
        # "services/explo/system-password" = { };
        # "services/explo/api-key" = { };
        # "services/explo/admin-system-password" = { };
        "tokens/plex" = { };
      };
      templates."explo.env" = {
        content = ''
          API_KEY=${config.sops.placeholder."tokens/plex"}
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
