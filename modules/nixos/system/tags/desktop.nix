{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "desktop") {
    # Enable core GUI features
    gui.enable = lib.mkDefault true;
    services.pipewire.enable = lib.mkDefault true;

    # Enable features for desktop systems
    # (LaTeX is deliberately NOT tag-driven: hosts opt in via `programs.latex.enable`.)
    system.autoUpgrade.enable = lib.mkDefault true;
  };
}
