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
      traefik.dynamicConfigOptions = lib.networking.traefikConfig {
        serviceName = "scrutiny";
        url = "kuchiki.sparrow-yo.ts.net";
        inherit (config.services.scrutiny.settings.web.listen) port;
        path = config.services.scrutiny.settings.web.listen.basepath;
      };
    };
  };
}
