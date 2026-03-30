{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "desktop" config.system.tags) {
    # Enable core GUI features
    display-manager.enable = lib.mkDefault true;
    desktop-environment.enable = lib.mkDefault true;
    programs.enable = lib.mkDefault true;

    # Enable features for desktop systems (GUI, LaTeX, upgrades)
    latex.enable = lib.mkDefault true;
    upgrades.enable = lib.mkDefault true;
  };
}
