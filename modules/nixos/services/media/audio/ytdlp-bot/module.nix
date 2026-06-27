{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ytdlp-bot;

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ pytelegrambotapi ]);

  botPackage = pkgs.writeScriptBin "ytdlp-bot" ''
    #!${pythonEnv}/bin/python
    ${builtins.readFile ./bot.py}
  '';

in
{
  options.services.ytdlp-bot = {
    enable = lib.mkEnableOption "YouTube to Plex Telegram Bot";

    # --- New Configurable User & Group ---
    user = lib.mkOption {
      type = lib.types.str;
      default = "ytdlp-bot";
      description = "System user account under which the bot runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "ytdlp-bot";
      description = "System group under which the bot runs.";
    };
    # -------------------------------------

    plexMusicDir = lib.mkOption {
      type = lib.types.str;
      description = "Directory where the bot will save the tagged mp3 files.";
    };

    authorizedUserId = lib.mkOption {
      type = lib.types.str;
      description = "Your personal Telegram User ID to authorize interactions.";
    };

    botTokenPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the file containing the bot token.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Dynamically create the user and group based on the options
    users.users."${cfg.user}" = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups."${cfg.group}" = { };

    systemd.services.ytdlp-bot = {
      description = "YouTube to Plex Telegram Bot";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.yt-dlp ];

      environment = {
        BOT_TOKEN_PATH = cfg.botTokenPath;
        AUTHORIZED_USER_ID = cfg.authorizedUserId;
        PLEX_MUSIC_DIR = cfg.plexMusicDir;
      };

      serviceConfig = {
        Type = "simple";
        # Inject the user and group into systemd
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${botPackage}/bin/ytdlp-bot";
        Restart = "on-failure";
        RestartSec = "10";
      };
    };
  };
}
