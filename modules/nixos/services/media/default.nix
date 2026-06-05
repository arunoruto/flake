{
  config,
  lib,
  ...
}:
{
  imports = [
    ./audio
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
    openFirewall = lib.mkEnableOption "Open all firewall ports of media services";
  };

  config =
    let
      cfg = config.services.media;
    in
    lib.mkMerge [
      (lib.mkIf cfg.enable {
        services = {
          radarr.enable = lib.mkDefault cfg.services;
          sonarr.enable = lib.mkDefault cfg.services;
          arr.enable = lib.mkDefault cfg.services;
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

        media.external-drives.enable = lib.mkDefault false;
      })
      (lib.mkIf (lib.elem "desktop" config.system.tags) {
        services.pipewire.enable = lib.mkDefault true;
      })
      (lib.mkIf (!(lib.elem "desktop" config.system.tags)) {
        services.pipewire.enable = lib.mkForce false;
      })
    ];
}
