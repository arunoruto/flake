{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "tinypc" config.system.tags) {
    display-manager.enable = false;
    desktop-environment.enable = false;
    programs.enable = false;

    latex.enable = false;
    programming.enable = false;
    upgrades.enable = true;

    programs.nix-ld.enable = lib.mkForce false;
    services = {
      kanata.enable = lib.mkForce false;
      keyd.enable = lib.mkForce false;
    };
  };
}
