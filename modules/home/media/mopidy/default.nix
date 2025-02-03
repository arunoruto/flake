{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    mopidy.enable = lib.mkEnableOption "Enable mopidy";
  };

  config = lib.mkIf config.mopidy.enable {
    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [
        mopidy-mpd
        mopidy-ytmusic

        mopidy-mpris
        mopidy-mopify
      ];
    };

    home.packages = with pkgs; [
      mopidy
      mopidy-ytmusic
    ];
  };
}
