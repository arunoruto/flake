{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.tpm.enable = lib.mkEnableOption "Enable TPM secuirty options";
  config = lib.mkIf config.tpm.enable {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      abrmd.enable = true;
      tctiEnvironment.enable = true;
    };

    environment.systemPackages = with pkgs.unstable; [
      ssh-tpm-agent
      tpm2-tools
    ];
  };
}
