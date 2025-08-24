{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "headless" config.system.tags) {
    # Disable custom GUI flags
    display-manager.enable = lib.mkForce false;
    desktop-environment.enable = lib.mkForce false;
    programs.enable = lib.mkForce false;

    # Disable common GUI services
    services.xserver.enable = lib.mkForce false;
    # sound.enable = lib.mkForce false;
  };
}
