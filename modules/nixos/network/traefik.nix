{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.traefik.enable {
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
        dataDir = "/etc/traefik";
        staticConfigOptions = {
          global.sendAnonymousUsage = true; # Send anonymous usage data
          log.level = "INFO";
          # accesslog.format = "json";
          api = {
            debug = false;
            dashboard = false;
            insecure = false;
          };
          # ping = { };
          entryPoints = {
            web = {
              address = ":80";
              http.redirections.entryPoint = {
                to = "websecure";
                scheme = "https";
              };
              forwardedHeaders.trustedIPs = lib.optionals config.services.cloudflared.enable cloudflareIPs;
            };
            websecure = {
              address = ":443";
              http.tls = { };
              forwardedHeaders.trustedIPs = lib.optionals config.services.cloudflared.enable cloudflareIPs;
            };
          };
          providers =
            {
              providersThrottleDuration = "2s";
            }
            # // lib.optionalAttrs (!config.virtualisation.docker.enable) {
            #   file = {
            #     watch = true;
            #     # directory = "${config.services.traefik.dataDir}/dynamic";
            #   };
            # }
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
                storage = "${config.services.traefik.dataDir}/acme.json";
                httpChallenge.entryPoint = "web";
                tlsChallenge = { };
              };
              ts.tailscale = { };
              cf.acme = {
                inherit email;
                storage = "${config.services.traefik.dataDir}/acme.json";
                dnsChallenge = {
                  provider = "cloudflare";
                  propagation.delayBeforeChecks = 90;
                  resolvers = [
                    "1.1.1.1:53"
                    "1.0.0.1:53"
                  ];
                };
                # caServer="https://acme-staging-v02.api.letsencrypt.org/directory";
              };
            };
        };
      };
  };
}
