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
    rev = "fbc9afaaac0fb40ac81ff054ddae9660a7716574";
    hash = "sha256-DQGrrFDSAHLJMj26inTxk7jiLFm3cLI4jgCZX1mNZhA=";
  };
in {
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = true;
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    # image = "${wallpapers}/art/kanagawa/kanagawa-van-gogh.jpg";
    image = "${wallpapers}/${image}";
    targets = {
      nixvim.enable = false;
    };
  };
}
