{
  config,
  lib,
  ...
}:
{
  imports = [
    ./arr.nix
    ./plex.nix
  ];
  options = {
    media.enable = lib.mkEnableOption "Enable media services";
  };

  config = lib.mkIf config.media.enable {
    arr.enable = lib.mkDefault true;
    plex.enable = lib.mkDefault true;
  };
}
