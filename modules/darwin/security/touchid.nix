{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.darwin.security.touchid = {
    enable = lib.mkEnableOption "Enable TouchID for sudo authentication" // {
      default = true;
    };
  };

  config = lib.mkIf config.darwin.security.touchid.enable {
    security.pam.services.sudo_local = {
      enable = true;
      touchIdAuth = true;
    };
  };
}
