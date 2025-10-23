{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "laptop" config.system.tags) {
    latex.enable = true;
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
