{ config, ... }:
{
  nix.settings = {
    max-jobs = 1;
    cores = 0;
  };

  system.tags = [
    "tinypc"
    "headless"
  ];

  fwupd.enable = false;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # 16 GB
    }
  ];

  services = {
    pocket-id = {
      enable = true;
      settings.APP_URL = "https://id.arnaut.me";
    };
    tailscale.derper = {
      enable = true;
      verifyClients = true;
      domain = "derper.arnaut.me";
    };
    syncthing.relay.enable = false;
    traefik = {
      enable = true;
      staticConfigOptions = {
        # log.level = "DEBUG";
        log.level = "INFO";
        api = {
          debug = true;
          dashboard = true;
          insecure = true;
        };
        accessLog = {
          format = "common";
        };
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            www-arnaut = {
              rule = "Host(`arnaut.me`)";
              tls.certresolver = "cf";
              entrypoints = "websecure";
              priority = 3;
              middlewares = [ "www-arnaut" ];
              service = "noop@internal";
            };
            whoami = {
              rule = "Host(`whoami.arnaut.me`)";
              entrypoints = "websecure";
              tls.certresolver = "cf";
              # middlewares = [ "pocket-id" ];
              service = "whoami";
            };
            plex = {
              # rule = "Host(`bosflix.arnaut.me`) && Path(`/web`)";
              rule = "Host(`bosflix.arnaut.me`)";
              entrypoints = "websecure";
              tls.certresolver = "cf";
              service = "plex";
            };
          };
          middlewares.www-arnaut.redirectregex = {
            regex = "^https://arnaut\\.me/(.*)";
            replacement = "https://www.arnaut.me";
            permanent = true;
          };
          services = {
            whoami = {
              loadbalancer.servers = [
                {
                  url = "http://localhost:${builtins.toString config.services.whoami.port}";
                }
              ];
            };
            plex = {
              loadbalancer.servers = [
                {
                  url = "http://kuchiki.sparrow-yo.ts.net:32400";
                }
              ];
            };
          };
        };
      };
    };
    whoami.enable = true;
  };

  # systems.tags = [
  #   ""
  # ];
}
