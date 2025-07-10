{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  config = lib.mkIf config.services.homepage-dashboard.enable {
    services.homepage-dashboard = {
      package = pkgs.unstable.homepage-dashboard;
      allowedHosts = "kuchiki:8082";
      widgets = [
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
                  href = "http://${config.networking.hostName}:${port}";
                  widget = {
                    type = "radarr";
                    url = "http://localhost:${port}";
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
                  href = "http://${config.networking.hostName}:${port}";
                  widget = {
                    type = "sonarr";
                    url = "http://localhost:${port}";
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
      environmentFile =
        lib.mkDefault
          (pkgs.writeTextFile {
            name = "homepage-env";
            text = ''
              HOMEPAGE_FILE_RADARR_KEY=${config.sops.secrets."tokens/arr/radarr".path}
              HOMEPAGE_FILE_SONARR_KEY=${config.sops.secrets."tokens/arr/sonarr".path}
              HOMEPAGE_FILE_FINNHUB_KEY=${config.sops.secrets."tokens/finnhub".path}
            '';
          }).outPath;
    };
    sops.secrets."tokens/finnhub" = {
      mode = "0666";
      # inherit (config.services.recyclarr) group;
    };
  };
}
