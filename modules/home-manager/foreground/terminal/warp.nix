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
    rev = "b6891cc339b3a1bb70a5c3063add4bdbd0455603";
    hash = "sha256-ypzSeSWT2XfdjfdeE/lLdiRgRmxewAqiWhGp6jjF7hE=";
  };
in
{
  options.programs.warp.enable = lib.mkEnableOption "Enable warp terminal";

  config = lib.mkIf config.programs.warp.enable {
    home = {
      packages = [ pkgs.unstable.warp-terminal ];

      file.".local/share/warp-terminal/themes/catppuccin" = {
        source = "${catppuccin-warp}/themes";
      };
    };
  };
}
