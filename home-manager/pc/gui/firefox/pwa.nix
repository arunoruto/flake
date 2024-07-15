{pkgs, ...}: {
  # environment.systemPackages = [
  home.packages = [
    pkgs.firefoxpwa
  ];
  programs.firefox = {
    nativeMessagingHosts = [pkgs.firefoxpwa];
    # nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
}
