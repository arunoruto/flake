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

  # Driven by the upstream `security.tpm2.enable`; this module layers PKCS11,
  # abrmd, and the TPM tooling (age-plugin-tpm, tpm2-totp) on top.
  # NB: don't set `services.ssh-tpm-agent.enable` here — ssh-tpm-agent.nix sets
  # `security.tpm2.enable` from it, so gating on tpm2.enable would form a cycle.
  # ssh-tpm-agent defaults to off already.
  config = lib.mkIf config.security.tpm2.enable {
    security.tpm2 = {
      pkcs11.enable = true;
      abrmd.enable = true;
      # tctiEnvironment.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
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
