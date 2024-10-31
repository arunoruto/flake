{
  lib,
  config,
  ...
}:
{
  imports = [
    ./browsers
    ./steam.nix
    ./packages.nix

    ./wayland.nix
  ];

  options.gui.enable = lib.mkEnableOption "Setup GUI Modules";

  config = lib.mkIf config.gui.enable {
    gui.packages.enable = lib.mkDefault true;
    wayland.enable = lib.mkDefault true;

    browsers.enable = lib.mkDefault true;
    steam.enable = lib.mkDefault true;
  };
}
