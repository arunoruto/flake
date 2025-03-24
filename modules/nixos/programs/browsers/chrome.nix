{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    chrome.enable = lib.mkEnableOption "chrome";
  };

  config = lib.mkIf config.chrome.enable {
    environment.systemPackages = with pkgs; [
      (google-chrome.override {
        commandLineArgs =
          [
            "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
            # "--disable-features=WaylandFractionalScaleV1"
            # "--use-gl=egl" # Disable GPU/HW acceleration
            #"--enable-gpu-rasterization"
            #"--ignore-gpu-blacklist"
            #"--disable-gpu-driver-workarounds"
          ]
          ++ lib.optionals (!config.hosts.nvidia.enable) [
            "--ozone-platform=wayland"
          ];
      })
    ];

    # Enable native Wayland support for chrome/electron
    #environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
