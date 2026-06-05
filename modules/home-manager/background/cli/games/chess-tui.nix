{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.chess-tui;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.programs.chess-tui = {
    enable = lib.mkEnableOption "chess-tui is a terminal-based chess interface.";
    package = lib.mkPackageOption pkgs "chess-tui" { };
    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };
      description = "Settings for chess-tui.";
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.mkIf (cfg.settings != { }) {
      "chess-tui/config.toml".source = settingsFormat.generate "chess-tui-config.toml" cfg.settings;
    };
    home.packages = [ cfg.package ];
  };
}
