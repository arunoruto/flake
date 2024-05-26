{
  pkgs,
  ...
}: {
  fonts.packages = with pkgs; [
    aileron # helvetica
    jetbrains-mono
    liberation_ttf # Times New Roman, Arial, and Courier New
    (nerdfonts.override {fonts = ["FiraCode"];})
    noto-fonts-color-emoji
  ];

}
