{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.thunderbird.enable = lib.mkEnableOption "Enable thunderbird for Emailing";

  config = lib.mkIf config.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
      # package = pkgs.unstable.thunderbird-128;
      package = pkgs.thunderbird;
      profiles.mirza = {
        isDefault = true;
      };
    };
  };
}
