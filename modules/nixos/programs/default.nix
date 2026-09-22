{
  lib,
  ...
}:
{
  imports = [
    ./browsers
    ./gaming
    ./matlab
  ];

  # Host-facing switch for a graphical user session: home-manager maps it
  # onto `foreground.enable` (modules/home-manager/imports.nix), which is what
  # installs the GUI applications. Named `gui` to avoid colliding with
  # upstream `programs.*`.
  options.gui.enable = lib.mkEnableOption "GUI applications for the primary user";
}
