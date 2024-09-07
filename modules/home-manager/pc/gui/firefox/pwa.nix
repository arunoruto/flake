{
  pkgs,
  lib,
  config,
  ...
}: {
  options.firefox.pwa.enable = lib.mkEnableOption "Enable Zed, a rust based IDE";

  config = lib.mkIf config.firefox.pwa.enable {
    home.packages = [
      pkgs.firefoxpwa
    ];
    programs.firefox = {
      nativeMessagingHosts = [pkgs.firefoxpwa];
      # nativeMessagingHosts.packages = [pkgs.firefoxpwa];
    };
  };
}
