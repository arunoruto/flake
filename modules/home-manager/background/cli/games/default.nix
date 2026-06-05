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
      #   package = pkgs.unstable.chess-tui.overrideAttrs (
      #     final: prev: {
      #       version = "2.3.0-fix-readonly-config";
      #       src = pkgs.fetchFromGitHub {
      #         # https://github.com/thomas-mauran/chess-tui/commit/0c47707cb4bb05c025423b2aafbc91cf9ad2e129
      #         owner = "thomas-mauran";
      #         repo = "chess-tui";
      #         rev = "0c47707cb4bb05c025423b2aafbc91cf9ad2e129";
      #         hash = "sha256-kxnRDUaHJK32YwRCDVYC+8VtUpV0+vgIxgHJDQv5l10=";
      #       };

      #       cargoDeps = pkgs.rustPlatform.importCargoLock {
      #         lockFile = final.src + "/Cargo.lock";
      #         allowBuiltinFetchGit = true;
      #       };
      #       cargoHash = null;
      #     }
      #   );
      #   settings = {
      #     engine_path = lib.getExe pkgs.unstable.stockfish;
      #     display_mode = "DEFAULT";
      #     log_level = "OFF";
      #     bot_depth = 10;
      #     selected_skin_name = "Default";
      #   };
    };
  };
}
