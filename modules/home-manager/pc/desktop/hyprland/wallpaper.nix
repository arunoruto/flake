{
  config,
  lib,
  ...
}: {
  options.hypr.wallpaper.enable = lib.mkEnableOption "Configure hyprpaper for wallpaper settings";

  config = lib.mkIf config.hypr.wallpaper.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        # preload = config.stylix.image;
        # wallpaper = ",${config.stylix.image}";
        splash = true;
        ipc = false;
      };
    };
  };
}
