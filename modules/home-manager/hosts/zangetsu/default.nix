{
  lib,
  config,
  ...
}:
{
  # config = lib.mkIf (osConfig.networking.hostName == "zangetsu") {
  config = lib.mkIf (config.hostname == "zangetsu") {
    wayland.windowManager.hyprland.settings = {
      monitor = ",preferred,auto,1.175";
    };
  };
}
