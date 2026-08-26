{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "desktop") {
    # Enable core GUI features
    display-manager.enable = lib.mkDefault true;
    desktop-environment.enable = lib.mkDefault true;
    gui.enable = lib.mkDefault true;
    services.pipewire.enable = lib.mkDefault true;

    # Enable features for desktop systems
    # (LaTeX is deliberately NOT tag-driven: hosts opt in via `latex.enable`.)
    upgrades.enable = lib.mkDefault true;
  };
}
