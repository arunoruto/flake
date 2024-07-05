# https://danth.github.io/stylix/
{
  config,
  pkgs,
  ...
}: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    image = "${config.home.homeDirectory}/Pictures/wallpapers/art/kanagawa/kanagawa-van-gogh.jpg";
    targets = {
      # nixvim.enable = false;
    };
  };
}
