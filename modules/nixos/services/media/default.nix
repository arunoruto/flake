{
  config,
  lib,
  ...
}:
{
  imports = [
    ./audio
    ./arr
    ./downloaders
    ./players
    ./reading
    ./syncthing

    ./bosflix.nix
    ./external-drives.nix
    ./sound.nix
  ];

  options.services.media = {
    enable = lib.mkEnableOption "Enable media module";
    services = lib.mkEnableOption "Enable media services";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib";
      description = "Directory to store media data";
    };
    libraryDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "/mnt/storage/media/movies"
        "/mnt/storage/media/shows"
      ];
      description = ''
        Library roots shared between the media services. Each is kept owned by
        the `media` group and setgid, so that everything created underneath
        inherits the group instead of the creating service's private one.

        Without this a folder imported by radarr ends up `radarr:radarr` and the
        other services (bazarr writing subtitles, jellyfin and plex managing
        artwork) are left with only `other` permissions on it.
      '';
    };
    openFirewall = lib.mkEnableOption "Open all firewall ports of media services";
  };

  # Whether pipewire runs is decided by the tag modules (interactive tags
  # default it on, `server` defaults it off); see modules/nixos/system/tags/.
  config =
    let
      cfg = config.services.media;
    in
    lib.mkIf cfg.enable {
      services = {
        arr.enable = lib.mkDefault cfg.services;
        radarr.enable = lib.mkDefault cfg.services;
        sonarr.enable = lib.mkDefault cfg.services;
        jellyfin.enable = lib.mkDefault cfg.services;
        plex.enable = lib.mkDefault cfg.services;
        tautulli.enable = lib.mkDefault cfg.services;
      };

      users.groups.media = {
        gid = 420;
        members = [
          config.users.primaryUser
        ];
      };

      # The setgid bit is what makes this stick: new subdirectories inherit both
      # the `media` group and the bit itself, so the guarantee propagates down
      # the library without a recursive pass on every boot.
      systemd.tmpfiles.settings."10-media-libraries" = lib.genAttrs cfg.libraryDirs (_: {
        d = {
          user = config.users.primaryUser;
          group = config.users.groups.media.name;
          mode = "2775";
        };
      });

    };
}
