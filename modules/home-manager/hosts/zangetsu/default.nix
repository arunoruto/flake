{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf (osConfig.networking.hostName == "zangetsu") {
    wayland.windowManager.hyprland.settings = {
    monitor = ",preferred,auto,1.175";
  };
}
