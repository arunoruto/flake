{
  config,
  pkgs,
  lib,
  ...
# }@args:
}:
{
  imports = [
    # ./ags
    ./eww
    ./quickshell
    ./waybar
  ];

  # config = lib.mkIf (args ? nixosConfig) {
  config = lib.mkIf config.foreground.enable {
    bars = {
      # ags.enable = lib.mkDefault false;
      eww.enable = lib.mkDefault false;
      waybar.enable = lib.mkDefault false;
    };

    programs = {
      quickshell = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.unstable.quickshell;
        config-name = lib.mkDefault "caelestia";
        target = lib.mkDefault "hyprland-session";

        caelestia.enable = lib.mkDefault true;
      };
    };
  };
}
