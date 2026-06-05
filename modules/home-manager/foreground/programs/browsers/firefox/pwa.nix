{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.firefox.pwa.enable = lib.mkEnableOption "Enable Firefox PWA support";

  config = lib.mkIf config.programs.firefox.pwa.enable {
    home.packages = [
      pkgs.firefoxpwa
    ];
    programs.firefox = {
      nativeMessagingHosts = [ pkgs.firefoxpwa ];
      # nativeMessagingHosts.packages = [pkgs.firefoxpwa];
    };
  };
}
