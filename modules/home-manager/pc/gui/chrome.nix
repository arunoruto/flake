{
  config,
  lib,
  ...
}:
{
  options = {
    chrome.enable = lib.mkEnableOption "Enable extra flags for chrome";
  };

  config = lib.mkIf config.chrome.enable {
    home.file = {
      ".config/chrome-flags.conf".text = ''
        --enable-features=TouchpadOverscrollHistoryNavigation
        --enable-gpu-rasterization
        --ignore-gpu-blacklist
        --disable-gpu-driver-workarounds
      '';
    };
  };
}
