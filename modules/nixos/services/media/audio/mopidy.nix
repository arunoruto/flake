# Mopidy's extensions, whenever `services.mopidy` is on.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.mopidy.enable {
    services.mopidy.extensionPackages = with pkgs; [
      mopidy-mpd
      mopidy-ytmusic
    ];
  };
}
