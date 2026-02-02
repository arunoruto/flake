{
  osConfig,
  lib,
  pkgs,
  ...
}@args:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # Check if we're on NixOS (osConfig.system.tags exists)
  isNixOS = args ? osConfig && osConfig ? system && osConfig.system ? tags;
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
      laptop.enable = lib.mkEnableOption "Sensible defaults for laptops";
      tinypc.enable = lib.mkEnableOption "Sensible defaults for tinypcs";
      development.enable = lib.mkEnableOption "Enable development tools";
      headless.enable = lib.mkEnableOption "Sensible defaults for headless systems";
    };
  };

  config = lib.mkMerge [
    # NixOS-specific configuration (tags-based)
    (lib.mkIf isNixOS {
      hosts = {
        laptop.enable = lib.mkDefault (lib.elem "laptop" osConfig.system.tags);
        tinypc.enable = lib.mkDefault (
          (lib.elem "tinypc" osConfig.system.tags) || (lib.elem "headless" osConfig.system.tags)
        );
        development.enable = lib.mkDefault (lib.elem "development" osConfig.system.tags);
        headless.enable = lib.mkDefault (lib.elem "headless" osConfig.system.tags);
      };
      # hostname = lib.mkDefault osConfig.networking.hostName;
      keyboard = {
        layout = lib.mkDefault osConfig.services.xserver.xkb.layout;
        variant = lib.mkDefault osConfig.services.xserver.xkb.variant;
      };
      theming = {
        enable = lib.mkDefault osConfig.programs.enable;
        # image and scheme are handled by stylix
      };
    })

    # Darwin and NixOS common configuration
    (lib.mkIf (args ? osConfig) {
      foreground.enable = lib.mkDefault (
        if isDarwin then
          true # Always enable on Darwin
        else
          osConfig.programs.enable # Use NixOS custom option
      );
    })
  ];
}
