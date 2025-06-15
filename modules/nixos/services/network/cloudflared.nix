{
  config,
  lib,
  pkgs,
  ...
}:
let
  secret-file = "config/bosflix";
in
{
  config = lib.mkIf config.services.cloudflared.enable {
    services.cloudflared = {
      package = pkgs.unstable.cloudflared;
      tunnels = {
        "bosflix" = {
          credentialsFile = config.sops.secrets."${secret-file}".path;
          default = "http_status:404";
          ingress = {
            "infra.arnaut.me" = {
              path = "/prowlarr.*";
              service = "http://localhost:9696";
            };
          };
        };
      };
    };
    sops.secrets."${secret-file}" = {
      # mode = "0440";
      # inherit (config.services.traefik) group;
    };
    networking.firewall.allowedUDPPorts = [ 7844 ];
  };
}
