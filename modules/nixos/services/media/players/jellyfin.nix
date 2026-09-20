{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.jellyfin.enable {
    services.jellyfin =
      let
        cfg = config.services.media;
      in
      {
        package = lib.mkDefault pkgs.unstable.jellyfin;
        dataDir = lib.mkDefault "${cfg.dataDir}/jellyfin";
        openFirewall = lib.mkDefault config.services.media.openFirewall;
      };

    users.users.jellyfin.extraGroups =
      lib.optionals (config.users.groups ? "media") [
        config.users.groups.media.name
      ]
      # jellyfin-ffmpeg reaches the GPU through /dev/dri/renderD128, which is
      # only reachable today because udev happens to leave it world-writable.
      # Ask for the group that owns it rather than relying on that: a stricter
      # rule would otherwise turn hardware transcoding off with no error
      # beyond a sudden jump in CPU.
      ++ lib.optionals (config.users.groups ? "render") [
        config.users.groups.render.name
      ];
  };
}
