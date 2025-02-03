{ lib, pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = ",preferred,auto,1.175";
  };
}
