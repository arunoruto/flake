{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "laptop" config.system.tags) {
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
