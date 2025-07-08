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
  };
}
