{
  lib,
  config,
  ...
}:
{
  options.hosts.workstation.enable = lib.mkEnableOption "Sensible defaults for workstations";

  config = lib.mkIf config.hosts.workstation.enable {
    latex.enable = true;
    programming.enable = true;
    upgrades.enable = true;
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
