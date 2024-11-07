{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.serpl.enable = lib.mkEnableOption "Enable TUI for editing find/replace";

  config = lib.mkIf config.serpl.enable {
    home.packages = with pkgs; [
      unstable.serpl
    ];
  };
}
