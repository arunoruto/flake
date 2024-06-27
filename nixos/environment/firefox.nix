{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (wrapFirefox (firefox-unwrapped.override {
      pipewireSupport = true;
    }) {})
  ];
}
