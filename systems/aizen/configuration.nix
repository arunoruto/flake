{
  hosts.tinypc.enable = true;

  fwupd.enable = false;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # 16 GB
    }
  ];

  services = {
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

      };
      dynamicConfigOptions = {
        http = {
          routers = {
            www-arnaut = {
              # rule = "PathPrefix(`/`)";
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
              service = "whoami";
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
