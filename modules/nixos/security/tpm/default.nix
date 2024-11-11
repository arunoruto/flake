{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./ssh-tpm-agent.nix
  ];

  options.tpm.enable = lib.mkEnableOption "Enable TPM secuirty options";

  config = lib.mkIf config.tpm.enable {
    services.ssh-tpm-agent = {
      enable = false;
      package = pkgs.unstable.ssh-tpm-agent;
      # userProxyPath = "yubikey-agent/yubikey-agent.sock";
    };

    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      abrmd.enable = true;
      # tctiEnvironment.enable = true;
    };

    environment = {
      systemPackages = with pkgs.unstable; [
        age-plugin-tpm
        # tpm2-tools
        tpm2-totp
      ];
      sessionVariables = {
        # TSS2_LOG = "fapi+NONE";
        TPM2_PKCS11_TCTI = "tabrmd:";
        TPM2TOOLS_TCTI = "tabrmd:bus_type=system";
      };
    };
  };
}
