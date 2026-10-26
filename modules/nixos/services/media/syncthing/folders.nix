{
  config,
  lib,
  ...
}:
let
  sadoDeviceId = "5L6CA45-Q2JJ7WK-RYDURDI-MBRGQPB-VTJEZ7U-6M25S3M-YTXBLRR-IVA6PQY";
  # The off-tailnet *arr box these folders are shared out to. Not one of our
  # hosts, so it is only ever a syncthing peer.
  arrHoiDeviceId = "BAX67OS-4BRORCO-RLKEO5C-GECZD7K-DTLAEI5-DZNF5UN-UP7AFA3-JQ6T6AA";
in
{
  config = lib.mkIf config.services.syncthing.enable {
    # https://docs.syncthing.net/users/config.html
    services.syncthing.settings = lib.mkMerge [
      # SOURCE: shinji (bosflix) — shares out to sado, kuchiki and arr-hoi
      (lib.mkIf config.services.bosflix.enable (
        let
          # One spelling of this path, shared with the unit that creates these
          # directories setgid and with sabnzbd's complete_dir. bosflix asserts
          # that every folder declared under it is also in
          # services.bosflix.syncedFolders.
          inherit (config.services.bosflix) completedPath;
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
          # Not on our tailnet and with no name we can resolve, so global
          # discovery is the only way to reach it.
          devices.arr-hoi = {
            addresses = [ "dynamic" ];
            id = arrHoiDeviceId;
          };
          folders = {
            "mirza-music" = {
              enable = true;
              path = "${completedPath}/mirza-music";
              devices = [ "sado" ];
              ignorePerms = true;
              order = "oldestFirst";
            };
            "mirza-shows" = {
              enable = true;
              path = "${completedPath}/mirza-shows";
              devices = [ "kuchiki" ];
              ignorePerms = true;
              order = "oldestFirst";
            };
            "mirza-movies" = {
              enable = true;
              path = "${completedPath}/mirza-movies";
              devices = [ "kuchiki" ];
              ignorePerms = true;
              order = "oldestFirst";
            };
            # The off-tailnet peer's two folders, previously added by hand in
            # the web GUI. They have to live here: `overrideFolders` defaults
            # to true, so syncthing-init deletes every folder it does not find
            # in this list on each activation — which unshared these twice
            # already.
            #
            # `id` is pinned because the GUI generates a random folder ID and
            # the option otherwise defaults to the attribute name. Letting it
            # default would create a second, empty folder and delete the real
            # one, re-indexing (and re-pulling) ~75G.
            #
            # ignorePerms as for the mirza-* folders, and here it is load
            # bearing rather than cosmetic: sabnzbd drops the setgid bit when
            # it chmods its final folder to 0777, so the files underneath end
            # up sabnzbd:sabnzbd rather than :media. Syncthing can read them
            # but not chmod them, and a failed metadata write fails the whole
            # folder — tim-shows had been stuck in an hourly retry loop,
            # never once reaching "Up to Date".
            "tim-shows" = {
              enable = true;
              id = "my3do-g3d9a";
              path = "${completedPath}/tim-shows";
              devices = [ "arr-hoi" ];
              ignorePerms = true;
              order = "oldestFirst";
            };
            "tim-movies" = {
              enable = true;
              id = "inepe-nmldy";
              path = "${completedPath}/tim-movies";
              devices = [ "arr-hoi" ];
              ignorePerms = true;
              order = "oldestFirst";
            };
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
