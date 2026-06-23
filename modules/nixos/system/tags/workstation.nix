{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (lib.hasTag config "workstation") {
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
