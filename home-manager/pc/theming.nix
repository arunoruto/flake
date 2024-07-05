# https://danth.github.io/stylix/
{
  config,
  pkgs,
  ...
}: {
  stylix = {
    image = "${config.home.homeDirectory}/Pictures/wallpapers/art/kanagawa/kanagawa-van-gogh.jpg";
    cursor = {
      name = "Catppuccin-Macchiato-Dark-Cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
      size = 24;
    };
    fonts = {
      serif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      # serif = {
      #   name = "Roboto";
      #   package = pkgs.roboto;
      # };
      sansSerif = config.stylix.fonts.serif;
      # sansSerif = {
      #   name = "Roboto Serif";
      #   package = pkgs.roboto-serif;
      # };
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.fira-code-nerdfont;
      };
    };
    opacity = {
      terminal = 0.975;
    };
    targets = {
      firefox = {
        enable = true;
        profileNames = ["mirza"];
      };
      # hyprland.enable = true;
      # hyprpaper.enable = true;
      # helix.enable = false;
      # kde.enable = false;
      # mako.enable = false;
      # nixvim.enable = false;
    };
  };
}
