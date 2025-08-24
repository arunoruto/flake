{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "workstation" config.system.tags) {
    latex.enable = true;
    programming.enable = true;
    upgrades.enable = true;
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
