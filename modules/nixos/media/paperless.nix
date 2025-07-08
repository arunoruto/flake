{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.services.paperless.enable {
    services.paperless =
      let
        cfg = config.services.media;
      in
      {
        package = lib.mkDefault pkgs.unstable.paperless-ngx;
        dataDir = lib.mkDefault "${cfg.dataDir}/paperless";
        configureTika = lib.mkDefault true;
      };
  };
}
