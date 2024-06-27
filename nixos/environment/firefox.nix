{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (wrapFirefox (firefox-unwrapped.override {
      pipewireSupport = true;
    }) {})
  ];

  programs.firefox = {
    enable = true;
    languagePacks = ["de" "en-US"];
  };
}
