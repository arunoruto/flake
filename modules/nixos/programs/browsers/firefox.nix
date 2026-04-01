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
  config = lib.mkIf config.programs.firefox.enable {
    # environment.systemPackages = with pkgs; [
    #   (wrapFirefox (firefox-unwrapped.override {
    #     pipewireSupport = true;
    #   }) {})
    # ];

    programs.firefox = {
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
