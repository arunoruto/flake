# https://danth.github.io/stylix/
{
  inputs,
  pkgs,
  lib,
  theme,
  image,
  ...
}: let
  wallpapers = pkgs.fetchFromGitHub {
    owner = "arunoruto";
    repo = "wallpapers";
    rev = "8815698729ceff1f97fae5ab2bf930a9dd682198";
    hash = "sha256-uPaPAggLFmureDXqKcvwr2uMb24QuxQzbwCqTHNSIrg=";
  };
in {
  # imports = [
  #   inputs.stylix.homeManagerModules.stylix
  # ];

  stylix = {
    enable = true;
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    # image = "${wallpapers}/art/kanagawa/kanagawa-van-gogh.jpg";
    image = "${wallpapers}/${image}";
    targets = {
      nixvim.enable = false;
      vscode.enable = true;
    };
  };
}
