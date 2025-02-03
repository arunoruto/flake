{
  lib,
  pkgs,
  config,
  ...
}:
{
  # imports = [
  #   ./panel-service.nix
  # ];

  options.hypr.panel.enable = lib.mkEnableOption "Configure hyprpanel";

  config = lib.mkIf config.hypr.panel.enable {
    services.hyprpanel = {
      enable = true;
    };
    # wayland.windowManager.hyprland.settings.exec-once = [
    #   "${config.services.hyprpanel.package}/bin/hyprpanel"
    # ];
  };
}
