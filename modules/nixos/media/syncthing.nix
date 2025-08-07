{
  lib,
  pkgs,
  config,
  ...
}:
{
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
              id = "5TUMXMK-Z3FPRVY-RD2ASP3-J3MQK47-UKBPM3B-4XMVABX-UGLBFOM-NKG3HQ5";
            };
          };
        };
      };

    # users.users.syncthing.extraGroups = lib.optionals (config.users.groups ? "media") [
    #   config.users.groups.media.name
    # ];
    users.users.syncthing.extraGroups = lib.optionals config.services.paperless.enable [ "paperless" ];
  };
}
