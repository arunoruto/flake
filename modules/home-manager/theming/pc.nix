# https://danth.github.io/stylix/
{
  config,
  lib,
  ...
}:
{
  # NOTE: stylix is configured at system level (nixosModules.stylix or darwinModules.stylix)
  # which auto-configures home-manager settings
  # All stylix configuration has been moved to system level
  config = lib.mkIf config.desktop.enable {
    # Additional desktop-specific theming can be added here
  };
}
