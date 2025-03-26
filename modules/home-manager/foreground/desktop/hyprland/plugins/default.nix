{
  lib,
  config,
  ...
}:
{
  imports = [
    ./hy3.nix
  ];
  options.hypr.plugins.enable = lib.mkEnableOption "Default hyprland plugins config";

  config = lib.mkIf config.hypr.plugins.enable {
    hypr.plugins.hy3.enable = lib.mkDefault true;
  };
}
