{
  lib,
  config,
  ...
}:
{
  imports = [
    ./browsers
    ./gaming
    ./matlab
    ./gui-packages.nix
  ];

  # Host-facing toggle for GUI applications (browsers, Steam, GUI packages).
  # Named `gui` to avoid colliding with upstream `programs.*`.
  options.gui.enable = lib.mkEnableOption "GUI applications (browsers, Steam, ...)";

  config = lib.mkIf config.gui.enable {
    programs.packages.enable = lib.mkDefault true;

    browsers.enable = lib.mkDefault true;
    # TODO: make tag for gaming
    programs.steam.enable = lib.mkDefault true;
  };
}
