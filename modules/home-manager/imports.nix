{
  osConfig ? null,
  lib,
  pkgs,
  ...
}@args:
let
  # Check if we're on NixOS (osConfig.system.tags exists)
  isNixOS = osConfig != null && osConfig ? system && osConfig.system ? tags;
in
{
  imports = [
    ./background
    ./foreground
    ./media
    ./theming
  ];

  options = {
    hosts = {
      desktop.enable = lib.mkEnableOption "Desktop/GUI features";
      laptop.enable = lib.mkEnableOption "Sensible defaults for laptops";
      development.enable = lib.mkEnableOption "Enable development tools";
    };
  };

  config = lib.mkMerge [
    # NixOS-specific configuration (tags-based)
    (lib.mkIf isNixOS {
      hosts = {
        desktop.enable = lib.mkDefault (lib.elem "desktop" osConfig.system.tags);
        laptop.enable = lib.mkDefault (lib.elem "laptop" osConfig.system.tags);
        development.enable = lib.mkDefault (lib.elem "development" osConfig.system.tags);
      };
      # hostname = lib.mkDefault osConfig.networking.hostName;
      keyboard = {
        layout = lib.mkDefault osConfig.services.xserver.xkb.layout;
        variant = lib.mkDefault osConfig.services.xserver.xkb.variant;
      };
      theming = {
        enable = lib.mkDefault (lib.elem "desktop" osConfig.system.tags);
        # image and scheme are handled by stylix
      };
    })

    # Darwin and NixOS common configuration
    (lib.mkIf (osConfig != null) {
      foreground.enable = lib.mkDefault (
        if pkgs.stdenv.hostPlatform.isDarwin then
          (lib.elem "desktop" osConfig.system.tags)
        else
          osConfig.programs.enable # Use NixOS custom option
      );
    })

    # Standalone home-manager configuration (no osConfig available)
    (lib.mkIf (osConfig == null) {
      hosts = {
        desktop.enable = lib.mkDefault false;
        laptop.enable = lib.mkDefault false;
        development.enable = lib.mkDefault false;
      };
      foreground.enable = lib.mkDefault true;
      theming.enable = lib.mkDefault true;
    })
  ];
}
