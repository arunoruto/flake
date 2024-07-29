{
  config,
  lib,
  ...
}: {
  options = {
    media.enable = lib.mkEnableOption "Enable media services";
  };

  config = lib.mkIf config.plex.enable {
    plex.enable = true;
  };
}
