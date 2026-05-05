{
  config,
  lib,
  ...
}:
let
  sadoDeviceId = "5L6CA45-Q2JJ7WK-RYDURDI-MBRGQPB-VTJEZ7U-6M25S3M-YTXBLRR-IVA6PQY";
  kuchikiDeviceId = "C4TO46K-P5LXFD6-NULLWDR-A5MYGJ2-EQDBNOC-CZHYJNJ-33DJHWA-SPQ6RQ7";
in
{
  config = lib.mkIf config.services.syncthing.enable {
    services.syncthing.settings = lib.mkMerge [
      # SOURCE: shinji (bosflix) — shares out to sado and kuchiki
      (lib.mkIf config.bosflix.enable (
        let
          drivePath = builtins.toString config.bosflix.drivePath;
        in
        {
          devices.sado = {
            addresses = [
              "dynamic"
              "tcp://sado"
              "tcp://sado:22000"
              "quic://sado:22000"
            ];
            id = sadoDeviceId;
          };
          folders."mirza-music" = {
            enable = true;
            path = "${drivePath}/complete/mirza-music";
            devices = [ "sado" ];
          };
          folders."mirza-shows" = {
            enable = true;
            path = "${drivePath}/complete/mirza-shows";
            devices = [ "kuchiki" ];
          };
          folders."mirza-movies" = {
            enable = true;
            path = "${drivePath}/complete/mirza-movies";
            devices = [ "kuchiki" ];
          };
        }
      ))

      # TARGET: sado (lidarr) — receives music
      (lib.mkIf config.services.lidarr.enable {
        folders."mirza-music" = {
          enable = true;
          path = "/mnt/flash/downloads/mirza-music";
          devices = [ "shinji" ];
        };
      })

      # TARGET: kuchiki (sonarr) — receives shows
      (lib.mkIf config.services.sonarr.enable {
        folders."mirza-shows" = {
          enable = true;
          path = "/mnt/storage/downloads/mirza-shows";
          devices = [ "shinji" ];
        };
      })

      # TARGET: kuchiki (radarr) — receives movies
      (lib.mkIf config.services.radarr.enable {
        folders."mirza-movies" = {
          enable = true;
          path = "/mnt/storage/downloads/mirza-movies";
          devices = [ "shinji" ];
        };
      })
    ];
  };
}
