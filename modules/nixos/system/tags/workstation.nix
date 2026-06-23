{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "workstation") {
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
