{
  config,
  lib,
  ...
}: {
  options = {
    fingerprint = lib.mkEnableOption "Enable fingerprint scanner support";
  };

  config = lib.mkIf config.fingerprint {
    # Enable fingerprint support with goodix (framework)
    services.fprintd.enable = true;
  };
}
