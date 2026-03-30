{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.elem "workstation" config.system.tags) {
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
