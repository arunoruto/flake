# https://danth.github.io/stylix/
{
  inputs,
  pkgs,
  lib,
  theme,
  stylix-config,
  ...
}: let
  wallpapers = pkgs.fetchFromGitHub {
    owner = "arunoruto";
    repo = "wallpapers";
    rev = "0814f66ec93e546c57bef0bdf5bf60cde401cf32";
    hash = "sha256-sCVHHUK13BiN6c+13Ca1wQidmBvrDoGBuJGlg2pXuo4=";
  };
in {
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = true;
    # base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    # image = "${wallpapers}/art/kanagawa/kanagawa-van-gogh.jpg";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${stylix-config.theme}.yaml";
    image = "${wallpapers}/${stylix-config.image}";
    targets = {
      nixvim.enable = false;
    };
  };
}
