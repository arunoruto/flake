{
  inputs,
  pkgs,
  lib,
  config,
  username,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

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
      base16Scheme = lib.mkDefault "${pkgs.unstable.base16-schemes}/share/themes/${config.theming.scheme}.yaml";
      image = inputs.wallpapers + "/${config.theming.image}";
      polarity = config.home-manager.users.${username}.stylix.polarity;
      cursor = lib.optionalAttrs (config.programs.enable
      ) config.home-manager.users.${username}.stylix.cursor;
      # if (config.programs.enable) then config.home-manager.users.${username}.stylix.cursor else { };
      # fonts =
      #   if (config.gui.enable)
      #   then config.home-manager.users.${username}.stylix.fonts
      #   else {};
      targets = {
        # lightdm.enable = true;
      };
    };
  };
}
