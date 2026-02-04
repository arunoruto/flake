{
  lib,
  pkgs,
  config,
  inputs,
  osConfig ? null,
  ...
}@args:
{
  imports = [
    ./chrome.nix
    ./firefox
    inputs.zen-browser.homeModules.default
  ];

  config = lib.mkIf config.foreground.enable {
    programs =
      let
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
        ]
        ++ lib.optionals (osConfig != null && !osConfig.hosts.nvidia.enable) [
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
        firefox.enable = lib.mkDefault false;
        google-chrome.enable = lib.mkDefault (pkgs.stdenv.hostPlatform.system == "x86_64-linux");
        vivaldi.enable = lib.mkDefault false;
        zen-browser = {
          enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux; # Only enable on Linux
          # package = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default.override {
          #   desktopIconName = "zen";
          # };
        };
      } update;

    home = {
      packages = [
        # inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ lib.optionals config.programs.vivaldi.enable [ pkgs.vivaldi-ffmpeg-codecs ];
      # sessionVariables = {
      #   # Firefox
      #   BROWSER = "${config.programs.firefox.finalPackage}/bin/firefox";
      # };
    };
  };
}
