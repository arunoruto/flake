# VimJoyer: https://www.youtube.com/watch?v=GaM_paeX7TI
{config, ...}: {
  imports = [
    ./arcwtf.nix
    ./pwa.nix
  ];
  programs.firefox = {
    enable = true;
    # languagePacks = ["de" "en-US"];
    # TODO: warning: The cfg.enableGnomeExtensions argument for `firefox.override` is deprecated, please add `pkgs.gnome-browser-connector` to `nativeMessagingHosts` instead
    enableGnomeExtensions = true;

    profiles.mirza = {
      # https://nur.nix-community.org/repos/rycee/
      # extensions = with config.nur.repos.rycee.firefox-addons; [
      #   bitwarden
      #   grammarly
      #   mal-sync
      #   ublock-origin

      #   augmented-steam
      #   protondb-for-steam
      #   steam-database
      # ];

      settings = {
        "browser.startup.page" = 3;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };
}
