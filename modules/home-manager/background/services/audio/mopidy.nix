# Mopidy's extensions and CLI, whenever home-manager's `services.mopidy` is on.
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
      mopidy-mpris
      mopidy-mopify
    ];

    home.packages = with pkgs; [
      mopidy
      mopidy-ytmusic
    ];
  };
}
