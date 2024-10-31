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

  options.firefox.enable = lib.mkEnableOption "Enable firefox for browsing the web";

  config = lib.mkIf config.firefox.enable {
    firefox.pwa.enable = true;

    programs.firefox = {
      enable = true;
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
