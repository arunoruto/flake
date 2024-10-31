{
  lib,
  pkgs,
  config,
  ...
}:
let
  catppuccin-warp = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "warp";
    rev = "7e3328b346ebe5ca7c59cfaa2b4bce755db62094";
    sha256 = "sha256-pUmO0po/fSPXIcKstWocCSX+Yg5l+H9JsEva+pCLNhI=";
  };
in
{
  options.warp.enable = lib.mkEnableOption "Enable warp terminal";

  config = lib.mkIf config.warp.enable {
    home = {
      packages = with pkgs; [
        unstable.warp-terminal
      ];

      file.".local/share/warp-terminal/themes/catppuccin" = {
        source = "${catppuccin-warp}/themes";
      };
    };
  };
}
