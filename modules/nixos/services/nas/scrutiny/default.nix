{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./collector.nix ];

  config = lib.mkIf config.services.scrutiny.enable {
    services = {
      scrutiny = {
        package = pkgs.unstable.scrutiny;
        openFirewall = true;
        settings = {
          web.listen.basepath = "/scrutiny";
        };
      };
      traefik.dynamicConfigOptions = lib.optionalAttrs config.services.scrutiny.enable (
        lib.networking.traefikConfig {
          serviceName = "scrutiny";
          url = "kuchiki.sparrow-yo.ts.net";
          port = config.services.scrutiny.settings.web.listen.port;
          path = config.services.scrutiny.settings.web.listen.basepath;
        }
      );
    };
  };
}
