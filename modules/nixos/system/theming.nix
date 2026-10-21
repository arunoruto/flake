{
  inputs,
  pkgs,
  lib,
  config,
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
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${config.theming.scheme}.yaml";
      # base16Scheme = lib.mkDefault "${pkgs.unstable.base16-schemes}/share/themes/${config.theming.scheme}.yaml";
      image = inputs.wallpapers + "/${config.theming.image}";
      polarity = lib.mkDefault "dark";
      # Disable system-level cursor - let home-manager control the cursor
      cursor = lib.mkForce null;
      # Stylix's overlays patch packages themselves: gnome-shell (the GDM
      # login screen theme), nixos-icons (a recoloured snowflake, which gdm
      # and everything built on it pulls in) and gtksourceview{,4,5}. Each
      # changes hashes that nobody caches, so every nixpkgs bump rebuilt
      # most of GNOME locally. The home-manager targets theme the user
      # sessions without touching packages (gtksourceview's stylix.xml goes
      # to ~/.local/share), so only the login screen falls back to stock.
      overlays.enable = false;
      targets = {
        # lightdm.enable = true;
        qt.enable = false;
      };
    };
  };
}
