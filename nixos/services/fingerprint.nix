{
  config,
  lib,
  ...
}: {
  options = {
    fingerprint.enable = lib.mkEnableOption "Enable fingerprint scanner support";
  };

  config = lib.mkIf config.fingerprint.enable {
    # Enable fingerprint support with goodix (framework)
    services.fprintd.enable = true;
  };
}
