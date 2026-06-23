{
  osConfig ? null,
  lib,
  pkgs,
  ...
}:
let
  # Check if we're on NixOS (osConfig.system.tags exists)
  isNixOS = osConfig != null && osConfig ? system && osConfig.system ? tags;

  # Home-manager's only tag use is the foundational hosts.* mapping below.
  # Routing that through the stylix-style `config.lib.tags.hasTag` option causes
  # infinite recursion (forcing config.lib drags in modules that read hosts.*),
  # so HM keeps a small local predicate against osConfig. nixos/darwin use
  # config.lib.tags.hasTag, where hasTag feeds leaf options (no cycle).
  hasTag = tag: isNixOS && lib.elem tag osConfig.system.tags;
in
{
  imports = [
    ./background
    ./foreground
    ./theming
  ];

  options = {
    hosts = {
      desktop.enable = lib.mkEnableOption "Desktop/GUI features";
      laptop.enable = lib.mkEnableOption "Sensible defaults for laptops";
      workstation.enable = lib.mkEnableOption "Non-portable interactive workstation";
      development.enable = lib.mkEnableOption "Enable development tools";
    };
  };

  config = lib.mkMerge [
    # NixOS-specific configuration (tags-based)
    (lib.mkIf isNixOS {
      hosts = {
        desktop.enable = lib.mkDefault (hasTag "desktop");
        laptop.enable = lib.mkDefault (hasTag "laptop");
        workstation.enable = lib.mkDefault (hasTag "workstation");
        development.enable = lib.mkDefault (hasTag "development");
      };
      # hostname = lib.mkDefault osConfig.networking.hostName;
      keyboard = {
        layout = lib.mkDefault osConfig.services.xserver.xkb.layout;
        variant = lib.mkDefault osConfig.services.xserver.xkb.variant;
      };
      theming = {
        enable = lib.mkDefault (hasTag "desktop");
        # image and scheme are handled by stylix
      };
    })

    # Darwin and NixOS common configuration
    (lib.mkIf (osConfig != null) {
      foreground.enable = lib.mkDefault (
        if pkgs.stdenv.hostPlatform.isDarwin then (hasTag "desktop") else osConfig.programs.enable # Use NixOS custom option
      );
    })

    # Standalone home-manager configuration (no osConfig available)
    (lib.mkIf (osConfig == null) {
      hosts = {
        desktop.enable = lib.mkDefault false;
        laptop.enable = lib.mkDefault false;
        workstation.enable = lib.mkDefault false;
        development.enable = lib.mkDefault false;
      };
      foreground.enable = lib.mkDefault true;
      theming.enable = lib.mkDefault true;
    })
  ];
}
