{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.serpl.enable = lib.mkEnableOption "Enable TUI for editing find/replace";

  config = lib.mkIf config.programs.serpl.enable {
    home.packages = with pkgs; [
      unstable.serpl
    ];
  };
}
