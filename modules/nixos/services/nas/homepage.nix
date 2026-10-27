{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  # radarr/sonarr live on kuchiki; every replica queries them over the tailnet.
  arrHost = "kuchiki";
in
{
  config = lib.mkIf config.services.homepage-dashboard.enable {
    services.homepage-dashboard = {
      package = pkgs.unstable.homepage-dashboard;
      # The public name aizen's traefik balances across both instances (it
      # passes the original Host through), plus this host for tailnet access
      # by short and full MagicDNS name.
      allowedHosts =
        let
          port = toString config.services.homepage-dashboard.listenPort;
          host = config.networking.hostName;
        in
        "home.arnaut.me,${host}:${port},${host}.${config.services.tailscale.tailnet}.ts.net:${port}";
      widgets = [
        # Which replica answered - the point of running two behind a balancer.
        { greeting.text = "served by ${config.networking.hostName}"; }
        {
          datetime = {
            text_size = "xl";
            locale = "de";
            format = {
              timeStyle = "short";
              dateStyle = "short";
            };
          };
        }
        {
          openmeteo = {
            label = "Dortmund";
            latitude = "51.5170043";
            longitude = "7.4582101";
            timezone = "Europe/Berlin";
            units = "metric";
            cache = 7; # Time in minutes to cache API responses, to stay within limits
            format.maximumFractionDigits = 1;
          };
        }
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
        {
          stocks = {
            provider = "finnhub";
            color = true;
            cache = 15;
            watchlist = [
              "TSM"
              "NVDA"
              "MSFT"
              "AAPL"
              "GOOGL"

              "AMD"
            ];
          };
        }
      ];
      services = [
        {
          "Arr" = [
            {
              "Radarr" =
                let
                  port = builtins.toString config.services.radarr.settings.server.port;
                in
                {
                  description = "Movie organizer/manager for usenet and torrent users.";
                  icon = "radarr.png";
                  href = "http://${arrHost}:${port}";
                  widget = {
                    type = "radarr";
                    url = "http://${arrHost}:${port}";
                    key = "{{HOMEPAGE_FILE_RADARR_KEY}}";
                  };
                };
            }
            {
              "Sonarr" =
                let
                  port = builtins.toString config.services.sonarr.settings.server.port;
                in
                {
                  description = "Smart PVR for newsgroup and bittorrent users.";
                  icon = "sonarr.png";
                  href = "http://${arrHost}:${port}";
                  widget = {
                    type = "sonarr";
                    url = "http://${arrHost}:${port}";
                    key = "{{HOMEPAGE_FILE_SONARR_KEY}}";
                  };
                };
            }
          ];
        }
        # {
        #   "My Second Group" = [
        #     {
        #       "My Second Service" = {
        #         description = "Homepage is the best";
        #         href = "http://localhost/";
        #       };
        #     }
        #   ];
        # }
      ];
      settings = {
        hideVersion = true;
        disableUpdateCheck = true;
        providers = {
          finnhub = "{{HOMEPAGE_FILE_FINNHUB_KEY}}";
        };
        background = {
          image = "https://github.com/arunoruto/wallpapers/blob/main/anime/train.png?raw=true";
          blur = "sm"; # sm, "", md, xl... see https://tailwindcss.com/docs/backdrop-blur
          saturate = 50; # 0, 50, 100... see https://tailwindcss.com/docs/backdrop-saturate
          brightness = 50; # 0, 50, 75... see https://tailwindcss.com/docs/backdrop-brightness
          opacity = 50; # 0-100
        };
      };
      environmentFiles = lib.mkDefault [
        (pkgs.writeTextFile {
          name = "homepage-env";
          text = ''
            HOMEPAGE_FILE_RADARR_KEY=${config.sops.secrets."tokens/arr/radarr".path}
            HOMEPAGE_FILE_SONARR_KEY=${config.sops.secrets."tokens/arr/sonarr".path}
            HOMEPAGE_FILE_FINNHUB_KEY=${config.sops.secrets."tokens/finnhub".path}
          '';
        }).outPath
      ];
    };
    sops.secrets = {
      "tokens/finnhub" = {
        mode = "0666";
        # inherit (config.services.recyclarr) group;
      };
      # Declared by the arr modules too where radarr/sonarr run; a replica
      # elsewhere still needs the keys for the widgets. Same mode as there.
      "tokens/arr/radarr".mode = "0666";
      "tokens/arr/sonarr".mode = "0666";
    };
  };
}
