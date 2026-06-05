{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./folders.nix ];
  config = lib.mkIf config.services.syncthing.enable {
    services.syncthing =
      let
        cfg = config.services.media;
      in
      {
        package = lib.mkDefault pkgs.syncthing;
        guiAddress = lib.mkDefault "0.0.0.0:8384";
        dataDir = lib.mkDefault "${cfg.dataDir}/syncthing";
        settings = {
          gui.insecureAdminAccess = true;
          devices = {
            seireitei = {
              addresses = [
                "dynamic"
                "tcp://seireitei"
                "tcp://seireitei:22000"
                "quic://seireitei:22000"
              ];
              id = "RPPP5DH-PXMPFAU-3BJJCDK-ULC55I6-YYBYA6Z-PP22QPD-NSMLOQT-45VHGQG";
            };
            shinji = {
              addresses = [
                "dynamic"
                "tcp://shinji"
                "tcp://shinji:22000"
                "quic://shinji:22000"
              ];
              id = "WA46FP7-Y3MA2X7-DP47SFH-4LGN2DM-VMWWHEP-2NF5TUO-RNOZEGM-V544MQT";
            };
          };
        };
      };

    users.users.syncthing.extraGroups =
      (lib.optionals (config.users.groups ? "media") [
        config.users.groups.media.name
      ])
      ++ (lib.optionals config.services.paperless.enable [ "paperless" ])
      ++ (lib.optionals config.services.lidarr.enable [ "lidarr" ])
      ++ (lib.optionals config.services.sabnzbd.enable [ "sabnzbd" ])
      ++ (lib.optionals config.services.qbittorrent.enable [ "qbittorrent" ]);

    systemd.services.syncthing.serviceConfig.UMask = "002";
  };
}
