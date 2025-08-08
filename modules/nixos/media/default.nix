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
    # ./qbittorrent.nix
    ./syncthing.nix

    ./arr
    ./plex
  ];

  options.services.media = {
    enable = lib.mkEnableOption "Enable media module";
    services = lib.mkEnableOption "Enable media services";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib";
      description = "Directory to store media data";
    };
    openFirewall = lib.mkEnableOption "Open all firewall ports of media services";
  };

  config =
    let
      cfg = config.services.media;
    in
    lib.mkIf cfg.enable {
      services =
        # lib.optionalAttrs cfg.services {
        {
          radarr.enable = lib.mkDefault cfg.services;
          sonarr.enable = lib.mkDefault cfg.services;
          arr.enable = lib.mkDefault cfg.services;
          jellyfin.enable = lib.mkDefault cfg.services;
          plex.enable = lib.mkDefault cfg.services;
          tautulli.enable = lib.mkDefault cfg.services;
        };

      users.groups.media = {
        gid = 420;
        members = [ config.username ];
      };

      media.external-drives.enable = lib.mkDefault true;
    };
}
