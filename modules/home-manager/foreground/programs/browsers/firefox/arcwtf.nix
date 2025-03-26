{ pkgs, ... }:
let
  arcwtf = pkgs.fetchFromGitHub {
    owner = "KiKaraage";
    repo = "ArcWTF";
    # rev = "v1.2-firefox";
    rev = "bb6f2b7ef7e3d201e23d86bf8636e5d0ea4bd68b";
    hash = "sha256-gyJiIVnyZOYVX6G3m4SSbsb7K9g4zKZWlrHphEIQwsY=";
  };
  profile = "mirza";
in
{
  programs.firefox = {
    profiles.${profile}.settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "svg.context-properties.content.enabled" = true;
      "uc.tweak.popup-search" = false;
    };
  };

  home.file = {
    ".mozilla/firefox/${profile}/chrome" = {
      source = arcwtf;
      # recursive = true;
    };
  };
}
