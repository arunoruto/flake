{ config, lib, ... }:

{
  imports = [
    ./module.nix
  ];

  config =
    let
      cfg = config.services.ytdlp-bot;
      sops-token = "tokens/telegram/ytdlp";
    in
    {
      services.ytdlp-bot = {
        enable = true;
        authorizedUserId = "757770344";
        plexMusicDir = "/mnt/flash/music/singles";
        botTokenPath = config.sops.secrets.${sops-token}.path;
      };

      users.users.${cfg.user}.extraGroups = lib.optionals (config.users.groups ? "media") [
        config.users.groups.media.name
      ];

      sops.secrets.${sops-token} = {
        owner = cfg.user;
        restartUnits = [ "ytdlp-bot.service" ];
      };
    };
}
