{
  lib,
  ...
}:
{
  imports = [
    ./chrome.nix
    ./firefox
  ];

  programs = {
    brave.enable = lib.mkDefault false;
    firefox.enable = lib.mkDefault true;
    google-chrome.enable = lib.mkDefault true;
    vivaldi.enable = lib.mkDefault false;
  };

  # home.sessionVariables = {
  #   # Firefox
  #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
  # };
}
