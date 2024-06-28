# VimJoyer: https://www.youtube.com/watch?v=GaM_paeX7TI
{config, ...}: {
  imports = [
    ./arcwtf.nix
  ];
  programs.firefox = {
    enable = true;
    # languagePacks = ["de" "en-US"];
    enableGnomeExtensions = true;

    profiles.mirza = {
      # https://nur.nix-community.org/repos/rycee/
      extensions = with config.nur.repos.rycee.firefox-addons; [
        bitwarden
        grammarly
        mal-sync
        ublock-origin

        augmented-steam
        protondb-for-steam
        steam-database
      ];

      settings = {
        "browser.startup.page" = 3;
      };
    };
  };
}
