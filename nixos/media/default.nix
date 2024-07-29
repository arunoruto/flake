{
  config,
  lib,
  ...
}: {
  imports = [
    ./plex.nix
  ];
  options = {
    media.enable = lib.mkEnableOption "Enable media services";
  };

  config = lib.mkIf config.media.enable {
    plex.enable = lib.mkDefault true;
  };
}
