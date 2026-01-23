{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./chess-tui.nix
  ];

  programs = {
    chess-tui = {
      enable = true;
      package = pkgs.unstable.chess-tui;
      settings = {
        engine_path = lib.getExe pkgs.unstable.stockfish;
        display_mode = "DEFAULT";
        log_level = "OFF";
        bot_depth = 10;
        selected_skin_name = "Default";
      };
    };
  };
}
