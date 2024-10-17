{
  pkgs,
  config,
  lib,
  ...
}: {
  options.vivaldi.enable = lib.mkEnableOption "Vivaldi Browser";

  config = lib.mkIf config.vivaldi.enable {
    environment.systemPackages = with pkgs; [
      (vivaldi.override {
        # https://github.com/NixOS/nixpkgs/issues/343806#issuecomment-2368835641
        # mesa = pkgs.mesa;
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
          "--ozone-platform=wayland"
          # "--disable-features=WaylandFractionalScaleV1"
          # "--use-gl=egl" # Disable GPU/HW acceleration
          #"--enable-gpu-rasterization"
          #"--ignore-gpu-blacklist"
          #"--disable-gpu-driver-workarounds"
        ];
      })
      vivaldi-ffmpeg-codecs
    ];

    # Enable native Wayland support for chrome/electron
    #environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
