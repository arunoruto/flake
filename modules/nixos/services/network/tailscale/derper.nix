{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.tailscale.derper.enable {
    services = {
      tailscale.derper = {
        package = pkgs.unstable.tailscale.derper;
        verifyClients = lib.mkDefault config.services.tailscale.enable;
      };
      nginx.enable = lib.mkForce false;
      traefik = {
        dynamicConfigOptions = {
          http = {
            routers = {
              derper-http = {
                rule = "Host(`derper.arnaut.me`)";
                entrypoints = "web";
                service = "derper";
                priority =
                  config.services.traefik.staticConfigOptions.entryPoints.web.http.redirections.entryPoint.priority
                  + 1;
              };
              derper-https = {
                rule = "Host(`derper.arnaut.me`)";
                tls.certresolver = "cf";
                entrypoints = "websecure";
                service = "derper";
              };
            };
            services = {
              derper = {
                loadbalancer.servers = [
                  {
                    url = "http://localhost:${builtins.toString config.services.tailscale.derper.port}";
                  }
                ];
              };
            };
          };
        };
      };
    };
  };
}
