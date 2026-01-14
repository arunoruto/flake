{
  config,
  lib,
  ...
}:
let
  cfg = config.services.harmonia;
in
{
  options.services.harmonia.openFirewall = lib.mkEnableOption "Open firewall for Harmonia";

  config = lib.mkIf cfg.enable {
    services.harmonia = {
      settings = {
        workers = 4;
        max_connection_rate = 2;
        priority = 50;
        # enable_compression = true;
      };
      signKeyPaths = [
        config.sops.secrets."services/harmonia/${config.networking.hostName}/secret".path
      ];
      # signKeyPaths = [ config.sops.secrets."tokens/harmonia".path ];
    };
    sops.secrets."services/harmonia/${config.networking.hostName}/secret" = {
      owner = "harmonia";
    };
    services.traefik =
      let
        name = "harmonia";
      in
      {
        dynamicConfigOptions = {
          http = {
            routers = {
              ${name} = {
                rule = "Host(`harmonia.bv.e-technik.tu-dortmund.de`)";
                tls.certresolver = "cf";
                entrypoints = "websecure";
                service = name;
              };
            };
            services = {
              ${name} = {
                loadbalancer.servers = [
                  {
                    url = "http://localhost:${toString 5000}";
                    # url = "http://localhost:${builtins.toString config.services.harmonia.port}";
                  }
                ];
              };
            };
          };
        };
      };
    nix.settings.allowed-users = [ "harmonia" ];
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ 5000 ];
  };
}
