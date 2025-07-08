{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.services.paperless.enable {
    services.paperless = {
      package = lib.mkDefault pkgs.unstable.paperless-ngx;
      configureTika = lib.mkDefault true;
    };
  };
}
