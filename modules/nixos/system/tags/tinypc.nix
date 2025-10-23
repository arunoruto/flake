{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "tinypc" config.system.tags) {
    latex.enable = false;
    upgrades.enable = true;

    programs.nix-ld.enable = lib.mkForce false;
    services = {
      kanata.enable = lib.mkForce false;
      keyd.enable = lib.mkForce false;
    };
  };
}
