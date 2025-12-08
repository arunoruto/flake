{
  config,
  lib,
  pkgs,
  ...
}:
let
  secret-file = "config/cloudflared/${config.networking.hostName}";
in
{
  disabledModules = [ "services/networking/cloudflared.nix" ];
  imports = [ ./cloudflared/new.nix ];

  options.services.cloudflared.defaultDomain = lib.mkOption {
    type = lib.types.str;
    description = "The domain to use for cloudflared tunnel.";
    default = "";
  };

  config = lib.mkIf config.services.cloudflared.enable {
    services.cloudflared = {
      package = pkgs.unstable.cloudflared;
      tunnels = {
        "${config.networking.hostName}" = {
          credentialsFile = config.sops.secrets."${secret-file}".path;
          default = "http_status:404";
        };
      };
      # tunnels = {
      #   "bosflix" = {
      #     credentialsFile = config.sops.secrets."${secret-file}".path;
      #     default = "http_status:404";
      #     ingress = [
      #       {
      #         hostname = "infra.arnaut.me";
      #         path = "/prowlarr.*";
      #         service = "http://localhost:9696";
      #       }
      #       {
      #         hostname = "infra.arnaut.me";
      #         path = "/web.*";
      #         service = "http://localhost:32400";
      #       }
      #     ];
      #     # ingress = {
      #     #   "infra.arnaut.me" = {
      #     #     path = "/prowlarr.*";
      #     #     service = "http://localhost:9696";
      #     #   };
      #     # };
      #   };
      # };
    };
    sops.secrets."${secret-file}" = {
      # mode = "0440";
      # inherit (config.services.traefik) group;
    };
    networking.firewall.allowedUDPPorts = [ 7844 ];
    boot.kernel.sysctl = {
      "net.core.rmem_max" = 7500000;
      "net.core.wmem_max" = 7500000;
    };
    environment.systemPackages = [ config.services.cloudflared.package ];
  };
}
