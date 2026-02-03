{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./cursors.nix
    ./fonts.nix
    ./icons.nix
    ./monitors.nix
    ./pc.nix
    ./stylix.nix # Asserts stylix is configured at system level
  ];

  options.theming = {
    enable = lib.mkEnableOption "Setup local theming";

    scheme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-macchiato";
      description = "Color scheme for theming (used by stylix)";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "linux/nixos.png";
      description = "Wallpaper image path (used by stylix)";
    };
  };

  config = lib.mkIf config.theming.enable {
    theming = {
      icons.enable = lib.mkDefault config.desktop.enable;
      fonts.enable = lib.mkDefault config.desktop.enable;
      # stylix.enable = lib.mkDefault true;
    };
  };
}
