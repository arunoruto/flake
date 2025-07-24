{
  lib,
  pkgs,
  config,
  inputs,
  osConfig,
  ...
}@args:
{
  imports = [
    ./chrome.nix
    ./firefox
  ];

  config = lib.mkIf config.foreground.enable {
    programs =
      let
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
        ]
        ++ lib.optionals (args ? nixosConfig && !osConfig.hosts.nvidia.enable) [
          "--ozone-platform=wayland"
        ];
        extensions = [
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
          { id = "epcnnfbjfcgphgdmggkamkmgojdagdnn"; } # ublock (normal)
          { id = "kekjfbackdeiabghhcdklcdoekaanoel"; } # MAL-sync
        ];
        browserList = [
          "brave"
          "vivaldi"
        ];
        update =
          lib.attrsets.recursiveUpdate
            (lib.attrsets.genAttrs (browserList ++ [ "google-chrome" ]) (name: {
              inherit commandLineArgs;
            }))
            (
              lib.attrsets.genAttrs browserList (name: {
                inherit extensions;
              })
            );
      in
      lib.attrsets.recursiveUpdate {
        brave.enable = lib.mkDefault false;
        firefox.enable = lib.mkDefault true;
        google-chrome.enable = lib.mkDefault true;
        vivaldi.enable = lib.mkDefault true;
      } update;

    home = {
      packages = [
        inputs.zen-browser.packages.${pkgs.system}.default
      ]
      ++ lib.optionals config.programs.vivaldi.enable [ pkgs.vivaldi-ffmpeg-codecs ];
      # sessionVariables = {
      #   # Firefox
      #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
      # };
    };
  };
}
