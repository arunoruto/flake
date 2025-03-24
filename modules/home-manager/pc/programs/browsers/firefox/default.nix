# VimJoyer: https://www.youtube.com/watch?v=GaM_paeX7TI
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # ./arcwtf.nix
    ./pwa.nix
  ];

  config = lib.mkIf config.programs.firefox.enable {
    firefox.pwa.enable = true;

    programs.firefox = {
      # languagePacks = ["de" "en-US"];

      profiles.mirza = {
        # extensions = with pkgs; [gnome-browser-connector];
        # # https://nur.nix-community.org/repos/rycee/
        # ++ (with config.nur.repos.rycee.firefox-addons; [
        #   #   bitwarden
        #   #   grammarly
        #   #   mal-sync
        #   #   ublock-origin

        #   #   augmented-steam
        #   #   protondb-for-steam
        #   #   steam-database
        # ]);

        settings = {
          "browser.startup.page" = 3;
          "media.ffmpeg.vaapi.enabled" = true;
        };
      };
    };
  };
}
