{
  config,
  lib,
  ...
}:
{
  imports = [
    ./bosflix.nix
    ./external-drives.nix
    ./immich.nix
    ./jellyfin.nix
    ./paperless.nix
    ./qbittorrent.nix
    ./syncthing.nix

    ./arr
    ./plex
  ];

  options.services.media = {
    enable = lib.mkEnableOption "Enable media services";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib";
      description = "Directory to store media data";
    };
    openFirewall = lib.mkEnableOption "Open all firewall ports of media services";
  };

  config = lib.mkIf config.services.media.enable {
    services = {
      radarr.enable = lib.mkDefault true;
      sonarr.enable = lib.mkDefault true;
      arr.enable = lib.mkDefault true;
      jellyfin.enable = lib.mkDefault true;
      plex.enable = lib.mkDefault true;
      tautulli.enable = lib.mkDefault true;
    };

    users.groups.media = {
      gid = 420;
      members = [ config.username ];
    };

    media.external-drives.enable = lib.mkDefault true;

  };
}
