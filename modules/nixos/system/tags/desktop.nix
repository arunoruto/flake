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
    # (LaTeX is deliberately NOT tag-driven: hosts opt in via `programs.latex.enable`.)
  };
}
