# https://danth.github.io/stylix/
{
  config,
  lib,
  ...
}: {
  # If desktop is enabled, also enable theming using stylix
  config = lib.mkIf config.desktop.enable {
    stylix = {
      opacity = {
        terminal = 0.95;
      };
      targets = {
        firefox = {
          enable = false;
          # profileNames = ["mirza"];
        };
        # hyprland.enable = true;
        # hyprpaper.enable = true;
        # helix.enable = false;
        # kde.enable = false;
        # mako.enable = false;
        # nixvim.enable = false;
      };
    };
  };
}
