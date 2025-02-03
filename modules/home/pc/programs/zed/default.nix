{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.zed.enable = lib.mkEnableOption "Enable Zed, a rust based IDE";

  config = lib.mkIf config.zed.enable {
    home.packages = with pkgs; [
      zed-editor
    ];
  };
}
