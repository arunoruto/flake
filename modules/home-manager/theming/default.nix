{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./cursors.nix
    ./darwin-targets.nix
    ./fonts.nix
    ./icons.nix
    ./pc.nix
    ./stylix # Asserts stylix is configured at system level
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

  config = lib.mkMerge [
    (lib.mkIf config.theming.enable {
      theming = {
        icons.enable = lib.mkDefault config.desktop.enable;
        fonts.enable = lib.mkDefault config.desktop.enable;
        # stylix.enable = lib.mkDefault true;
      };
    })
    # Stylix is on for every NixOS host, headless ones too. Its CLI targets
    # (fish, btop, starship, ...) only act on installed programs and keep SSH
    # sessions themed; these act regardless and only theme a desktop session
    # (gnome alone builds a GNOME Shell theme on every nixpkgs bump).
    (lib.mkIf (!config.foreground.enable) {
      stylix.targets =
        lib.genAttrs
          [
            "gnome"
            "gtk"
            "gtksourceview"
            "qt"
            "fontconfig"
            "font-packages"
            "xresources"
            "nixos-icons"
          ]
          (_: {
            enable = lib.mkDefault false;
          });
    })
  ];
}
