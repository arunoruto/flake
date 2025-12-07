{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.traefik;
  traefik-config-env = "traefik-config.env";
in
{
  config = lib.mkIf cfg.enable (
    let
      http-port = 80;
      https-port = 443;
    in
    {
      services.traefik =
        let
          cloudflareIPs = [

            "173.245.48.0/20"
            "103.21.244.0/22"
            "103.22.200.0/22"
            "103.31.4.0/22"
            "141.101.64.0/18"
            "108.162.192.0/18"
            "190.93.240.0/20"
            "188.114.96.0/20"
            "197.234.240.0/22"
            "198.41.128.0/17"
            "162.158.0.0/15"
            "104.16.0.0/13"
            "104.24.0.0/14"
            "172.64.0.0/13"
            "131.0.72.0/22"
            "2400:cb00::/32"
            "2606:4700::/32"
            "2803:f800::/32"
            "2405:b500::/32"
            "2405:8100::/32"
            "2a06:98c0::/29"
            "2c0f:f248::/32"
          ];
        in
        {
          package = pkgs.unstable.traefik;
          dataDir = "/etc/traefik";
          # environmentFiles = [
          #   (pkgs.writeText "cf-api-token" "CF_DNS_API_TOKEN_FILE=${
          #     config.sops.secrets."tokens/cf_dns_api_token".path
          #   }")
          # ];
          staticConfigOptions = {
            global.sendAnonymousUsage = true; # Send anonymous usage data
            log.level = lib.mkDefault "INFO";
            # log.level = lib.mkDefault "DEBUG";
            # accesslog.format = "json";
            api = {
              debug = lib.mkDefault false;
              dashboard = lib.mkDefault true;
              insecure = lib.mkDefault false;
            };
            # ping = { };
            entryPoints = {
              web = {
                address = ":${builtins.toString http-port}";
                http.redirections.entryPoint = {
                  to = "websecure";
                  scheme = "https";
                  priority = 10000;
                };
                forwardedHeaders.trustedIPs = lib.optionals config.services.cloudflared.enable cloudflareIPs;
              };
              websecure = {
                address = ":${builtins.toString https-port}";
                http.tls = { };
                forwardedHeaders.trustedIPs = lib.optionals config.services.cloudflared.enable cloudflareIPs;
              };
            };
            providers = {
              providersThrottleDuration = "2s";
            }
            // lib.optionalAttrs config.virtualisation.docker.enable {
              docker = {
                watch = true;
                network = "web";
                # Default host rule to containername.domain.example
                defaultRule = "Host(`{{ lower (trimPrefix `/` .Name )}}.homelab.arnaut.me`)"; # Replace with your domain
                # swarmModeRefreshSeconds = "15s";
                exposedByDefault = false;
                endpoint = "unix:///var/run/docker.sock";
              };
            };
            certificatesResolvers =
              let
                email = "mirza.arnaut45@gmail.com";
              in
              {
                myresolver.acme = {
                  inherit email;
                  storage = "${cfg.dataDir}/acme.json";
                  httpChallenge.entryPoint = "web";
                  tlsChallenge = { };
                };
                ts.tailscale = { };
                cf.acme = {
                  inherit email;
                  storage = "${cfg.dataDir}/acme.json";
                  dnsChallenge = {
                    provider = "cloudflare";
                    propagation.delayBeforeChecks = 90;
                    resolvers = [
                      "1.1.1.1:53"
                      "1.0.0.1:53"
                    ];
                  };
                };
              };
            experimental.plugins.traefik-oidc-auth = {
              modulename = "github.com/sevensolutions/traefik-oidc-auth";
              version = "v0.17.0";
            };
          };
          dynamicConfigOptions = lib.mkMerge [
            (lib.optionalAttrs cfg.staticConfigOptions.api.dashboard {
              http.routers.traefik-api = {
                # rule = "Host(`${config.networking.hostName}.${config.services.tailscale.tailnet}.ts.net`) && PathPrefix(`/dashboard`)";
                rule = "Host(`${config.networking.hostName}.${config.services.tailscale.tailnet}.ts.net`)";
                tls.certresolver = "ts";
                entrypoints = [ "websecure" ];
                service = "api@internal";
              };
            })
            # {
            #   http = {
            #     routers.paperless = {
            #       rule = "Host(`services.arnaut.me`) && PathPrefix(`/paperless`)";
            #       tls.certresolver = "cf";
            #       entrypoints = [ "websecure" ];
            #       service = "paperless";
            #     };
            #     services.paperless.loadbalancer.servers = [
            #       { url = "http://sado.sparrow-yo.ts.net:28981/paperless"; }
            #       # { url = "https://sado.sparrow-yo.ts.net/paperless"; }
            #     ];
            #   };
            # }
          ];
          # environmentFiles = [ config.sops.secrets."config/traefik".path ];
          environmentFiles = [ config.sops.templates."${traefik-config-env}".path ];
        };
      systemd = {
        tmpfiles.rules = lib.optionals (cfg.staticConfigOptions.providers ? file) [
          "d '${cfg.staticConfigOptions.providers.file.directory}' 0700 traefik traefik - -"
        ];
        services.traefik.environment = {
          CF_DNS_API_TOKEN_FILE = config.sops.secrets."tokens/cf_dns_api_token".path;
          CLOUDFLARE_EMAIL = config.sops.secrets."config/cloudflare/email".path;
          CLOUDFLARE_API_KEY_FILE = config.sops.secrets."config/cloudflare/api_key".path;
        };
      };
      sops = {
        secrets = {
          "tokens/cf_dns_api_token" = {
            mode = "0440";
            inherit (cfg) group;
          };
          "config/cloudflare/email" = {
            mode = "0440";
            inherit (cfg) group;
          };
          "config/cloudflare/api_key" = {
            mode = "0440";
            inherit (cfg) group;
          };
        };
        templates."${traefik-config-env}".content = ''
          CF_DNS_API_TOKEN_FILE=${config.sops.placeholder."tokens/cf_dns_api_token"}
          CLOUDFLARE_EMAIL_FILE=${config.sops.placeholder."config/cloudflare/email"}
          CLOUDFLARE_API_KEY_FILE=${config.sops.placeholder."config/cloudflare/api_key"}
        '';

      };
      networking.firewall.allowedTCPPorts = [
        http-port
        https-port
      ];
    }
  );
}
