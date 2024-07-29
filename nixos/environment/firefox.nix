{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    firefox.enable = lib.mkEnableOption "Configure firefox systemwide";
  };

  config = lib.mkIf config.firefox.enable {
    environment.systemPackages = with pkgs; [
      (wrapFirefox (firefox-unwrapped.override {
        pipewireSupport = true;
      }) {})
    ];

    programs.firefox = {
      enable = true;
      languagePacks = ["de" "en-US"];
    };
  };
}
