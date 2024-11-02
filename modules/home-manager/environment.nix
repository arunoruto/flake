{
  config,
  lib,
  user,
  ...
}:
{
  options.environment.enable = lib.mkEnableOption "Set env vars for user";

  config = lib.mkIf config.environment.enable {
    home.sessionVariables = {
      # EDITOR = "nvim";
      EDITOR = "hx";
      BROWSER = "firefox";
      WINIT_UNIX_BACKEND = "x11";
      FLAKE = "/home/${user}/.config/flake";

      # TPM
      # TPM2TOOLS_TCTI = "tabrmd:bus_type=system";
      TSS2_LOG = "fapi+NONE";
    };
  };
}
