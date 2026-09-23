{
  config,
  pkgs,
  ...
}:
{
  users.primaryUser = "mirza";

  system.tags = [ "server" ];

  nix = {
    settings = {
      max-jobs = 1;
      # 2-core netcup VM: cores = 0 meant "all of them", so a single build could
      # take the whole box out from under cloudflared. Leave one core free.
      cores = 1;
      max-substitution-jobs = 2;
      http-connections = 8;
    };
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # 16 GB
    }
  ];

  services = {
    fwupd.enable = false;
    # Websocket rather than the SSH method the work-side hosts use: the hub
    # cannot reach this VPS, so the agent dials out. Nothing listens here
    # either way - tailscale0 is already a trusted interface, and openFirewall
    # would put 45876 on the public netcup side for no gain.
    beszel.agent = {
      enable = true;
      package = pkgs.unstable.beszel;
      environment = {
        LOG_LEVEL = "info";
        HUB_URL = "https://infra.bv.e-technik.tu-dortmund.de";
        # Identifies us to the hub; still required in websocket mode.
        KEY_FILE = config.sops.secrets."tokens/beszel-marvin".path;
        # Two cores and a virtio framebuffer: there is no collector to find, so
        # skip the probe outright instead of letting auto-detection hunt. No
        # smartmon either - SMART on a virtual /dev/vda reports nothing, and it
        # would hand a public-facing box CAP_SYS_RAWIO and CAP_SYS_ADMIN.
        SKIP_GPU = true;
      };
      # EnvironmentFile, not TOKEN_FILE: systemd reads it as root, so the token
      # can stay 0400 instead of the 0444 the agent-read KEY_FILE needs.
      environmentFile = config.sops.templates."beszel-agent.env".path;
    };
    cloudflared = {
      enable = true;
      defaultDomain = "arnaut.me";
      tunnels."${config.networking.hostName}".ingress = [
        {
          hostname = "arr.${config.services.cloudflared.defaultDomain}";
          path = "/radarr.*";
          service = "http://kuchiki.${config.services.tailscale.tailnet}.ts.net:${toString config.services.radarr.settings.server.port}";
        }
        {
          hostname = "arr.${config.services.cloudflared.defaultDomain}";
          path = "/sonarr.*";
          service = "http://kuchiki.${config.services.tailscale.tailnet}.ts.net:${toString config.services.sonarr.settings.server.port}";
        }
        {
          hostname = "arr.${config.services.cloudflared.defaultDomain}";
          path = "/lidarr.*";
          service = "http://sado.${config.services.tailscale.tailnet}.ts.net:${toString config.services.lidarr.settings.server.port}";
        }
        {
          hostname = "arr.${config.services.cloudflared.defaultDomain}";
          path = "/readarr.*";
          service = "http://sado.${config.services.tailscale.tailnet}.ts.net:${builtins.toString config.services.readarr.settings.server.port}";
        }
        {
          hostname = "arr.${config.services.cloudflared.defaultDomain}";
          path = "/prowlarr.*";
          service = "http://shinji.${config.services.tailscale.tailnet}.ts.net:${toString config.services.prowlarr.settings.server.port}";
        }
      ];
    };
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

  sops = {
    # The hub's public key; the agent process reads this one itself.
    secrets."tokens/beszel-marvin".mode = "0444";
    secrets."tokens/beszel-ws" = { };
    templates."beszel-agent.env".content = ''
      TOKEN=${config.sops.placeholder."tokens/beszel-ws"}
    '';
  };

  # systems.tags = [
  #   ""
  # ];
}
