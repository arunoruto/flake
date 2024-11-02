{
  lib,
  config,
  ...
}:
{
  options.laptop.enable = lib.mkEnableOption "Sensible defaults for laptops";

  config = lib.mkIf config.laptop.enable {
    latex.enable = true;
    programming.enable = true;
    tpm.enable = lib.mkDefault true;
    yubikey.enable = lib.mkDefault true;
  };
}
