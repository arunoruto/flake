{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.lib.tags.hasTag "laptop") {
    security.tpm2.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
