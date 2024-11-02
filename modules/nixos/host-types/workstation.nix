{
  lib,
  config,
  ...
}:
{
  options.workstation.enable = lib.mkEnableOption "Sensible defaults for workstations";

  config = lib.mkIf config.workstation.enable {
    latex.enable = true;
    programming.enable = true;
    upgrades.enable = true;
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
