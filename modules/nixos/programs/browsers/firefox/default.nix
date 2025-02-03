{
  config,
  lib,
  pkgs,
  ...
}:
let
  # version = "firefox-unwrapped";
  version = "floorp";
in
{
  options.firefox.enable = lib.mkEnableOption "Configure firefox systemwide";

  config = lib.mkIf config.firefox.enable {
    # environment.systemPackages = with pkgs; [
    #   (wrapFirefox (firefox-unwrapped.override {
    #     pipewireSupport = true;
    #   }) {})
    # ];

    programs.firefox = {
      enable = true;
      package =
        if (version == "firefox-unwrapped") then
          pkgs.wrapFirefox (pkgs.${version}.override {
            pipewireSupport = true;
          }) { }
        else
          pkgs.${version};
      languagePacks = [
        "de"
        "en-US"
      ];
    };
  };
}
