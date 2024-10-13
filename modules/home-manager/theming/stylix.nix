# https://danth.github.io/stylix/
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
# let
#   wallpapers = pkgs.fetchFromGitHub {
#     owner = "arunoruto";
#     repo = "wallpapers";
#     rev = "8815698729ceff1f97fae5ab2bf930a9dd682198";
#     hash = "sha256-uPaPAggLFmureDXqKcvwr2uMb24QuxQzbwCqTHNSIrg=";
#   };
# in
{
  # imports = [
  #   inputs.stylix.homeManagerModules.stylix
  # ];
  options.theming = {
    # enable = lib.mkEnableOption "Setup icons for theming";

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
      enable = true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${config.theming.scheme}.yaml";
      image = "${inputs.wallpapers}/${config.theming.image}";
      targets = {
        nixvim.enable = false;
        vscode.enable = true;
      };
    };

    home.file = {
      ".config/stylix/palette.scss".text = ''
        $base00: ${config.lib.stylix.colors.withHashtag.base00};
        $base01: ${config.lib.stylix.colors.withHashtag.base01};
        $base02: ${config.lib.stylix.colors.withHashtag.base02};
        $base03: ${config.lib.stylix.colors.withHashtag.base03};
        $base04: ${config.lib.stylix.colors.withHashtag.base04};
        $base05: ${config.lib.stylix.colors.withHashtag.base05};
        $base06: ${config.lib.stylix.colors.withHashtag.base06};
        $base07: ${config.lib.stylix.colors.withHashtag.base07};
        $base08: ${config.lib.stylix.colors.withHashtag.base08};
        $base09: ${config.lib.stylix.colors.withHashtag.base09};
        $base0A: ${config.lib.stylix.colors.withHashtag.base0A};
        $base0B: ${config.lib.stylix.colors.withHashtag.base0B};
        $base0C: ${config.lib.stylix.colors.withHashtag.base0C};
        $base0D: ${config.lib.stylix.colors.withHashtag.base0D};
        $base0E: ${config.lib.stylix.colors.withHashtag.base0E};
        $base0F: ${config.lib.stylix.colors.withHashtag.base0F};
      '';
    };
  };
}
