{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.stylix.nixosModules.stylix];

  options.theming = {
    # enable = lib.mkEnableOption "Enable eye-candy";

    scheme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-macchiato";
      example = "gruvbox-material-dark-hard";
      description = ''
        Theme to be used with Stylix throughout your config
        Visit https://tinted-theming.github.io/base16-gallery/ to see some schemes
      '';
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "linux/nixos.png";
      example = "linux/nixos.png";
      description = ''
        Wallpaper to be used with Stylix throughout your config
        Visit https://github.com/arunoruto/wallpapers for possible images
      '';
    };
  };

  # config = lib.mkIf config.theming.enable {
  config = {
    stylix = {
      enable = lib.mkDefault true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${config.theming.scheme}.yaml";
      image =
        # pkgs.fetchFromGitHub {
        #   owner = "arunoruto";
        #   repo = "wallpapers";
        #   rev = "8815698729ceff1f97fae5ab2bf930a9dd682198";
        #   hash = "sha256-uPaPAggLFmureDXqKcvwr2uMb24QuxQzbwCqTHNSIrg=";
        # }
        inputs.wallpapers + "/${config.theming.image}";
      # cursor = {
      #   name = "catppuccin-macchiato-dark-cursors";
      #   package = pkgs.catppuccin-cursors.macchiatoDark;
      # };
      targets = {
        # lightdm.enable = true;
      };
    };
  };
}
