{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.tautulli.enable (
    let
      cfg = config.services.media;
    in
    {
      services = {
        tautulli = {
          package = lib.mkDefault pkgs.unstable.tautulli;
          dataDir = lib.mkDefault "${cfg.dataDir}/tautulli";
          openFirewall = lib.mkDefault cfg.openFirewall;
        };
      };

      # users.users.tautulli.extraGroups = lib.optionals (config.users.groups ? "media") [
      #   config.users.groups.media.name
      # ];
    }
  );
}
