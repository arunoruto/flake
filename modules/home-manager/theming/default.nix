{
  lib,
  config,
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

  options.theming.enable = lib.mkEnableOption "Setup local theming";

  config = lib.mkIf config.theming.enable {
    theming = {
      cursors.enable = lib.mkDefault config.desktop.enable;
      icons.enable = lib.mkDefault config.desktop.enable;
      fonts.enable = lib.mkDefault config.desktop.enable;
      # stylix.enable = lib.mkDefault true;
    };
  };
}
