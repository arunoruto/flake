{
  lib,
  config,
  ...
}:
{
  options.tinypc.enable = lib.mkEnableOption "Sensible defaults for tiny/mini PCs";

  config = lib.mkIf config.tinypc.enable {
    display-manager.enable = false;
    desktop-environment.enable = false;
    gui.enable = false;

    latex.enable = false;
    programming.enable = false;
    upgrades.enable = true;
    stylix.enable = false;
  };
}
