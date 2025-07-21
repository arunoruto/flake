{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.services.scrutiny.collector.enable {
    services.scrutiny.collector = {
      package = pkgs.unstable.scrutiny-collector;
      settings = {
        api.endpoint = lib.mkDefault "http://localhost:${builtins.toString config.services.scrutiny.settings.web.listen.port}${config.services.scrutiny.settings.web.listen.basepath}";
        host.id = lib.mkDefault config.networking.hostName;
      };
    };
  };
}
