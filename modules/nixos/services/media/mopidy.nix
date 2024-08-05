{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    mopidy.enable = lib.mkEnableOption "Enable mopidy";
  };

  config = lib.mkIf config.mopidy.enable {
    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [
        mopidy-mpd
        mopidy-ytmusic
      ];
    };
  };
}
