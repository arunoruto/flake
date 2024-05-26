{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    chrome.enable = lib.mkEnableOption "chrome";
  };

  config = lib.mkIf config.chrome.enable {
    environment.systemPackages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
          "--ozone-platform=wayland"
          #"--enable-gpu-rasterization"
          #"--ignore-gpu-blacklist"
          #"--disable-gpu-driver-workarounds"
        ];
      })
    ];

    # Enable native Wayland support for chrome/electron
    #environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
