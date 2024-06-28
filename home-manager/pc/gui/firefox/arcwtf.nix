{pkgs, ...}: let
  arcwtf = pkgs.fetchFromGitHub {
    owner = "KiKaraage";
    repo = "ArcWTF";
    rev = "v1.2-firefox";
    hash = "";
  };
in {
  programs.firefox = {
    profiles.mirza.settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "uc.tweak.popup-search" = true;
    };
  };

  home.file = {
    ".mozilla/firefox/mirza/chrome" = {
      source = arcwtf;
      recursive = true;
    };
  };
}
