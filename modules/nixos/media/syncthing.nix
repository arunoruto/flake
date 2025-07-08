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
      };
  };
}
