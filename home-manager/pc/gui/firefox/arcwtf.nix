{pkgs, ...}: let
  arcwtf = pkgs.fetchFromGitHub {
    owner = "KiKaraage";
    repo = "ArcWTF";
    rev = "v1.2-firefox";
    hash = "sha256-c1md5erWAqfmpizNz2TrM1QyUnnkbi47thDBMjHB4H0=";
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
