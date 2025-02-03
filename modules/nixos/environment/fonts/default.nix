{
  config,
  pkgs,
  ...
}:
{
  fonts.packages =
    (with pkgs; [
      aileron # helvetica
      jetbrains-mono
      dejavu_fonts
      liberation_ttf # Times New Roman, Arial, and Courier New
      # (nerdfonts.override { fonts = [ "FiraCode" ]; })
      # unstable.nerd-fonts.fira-code
      noto-fonts-color-emoji
    ])
    ++ [
      config.stylix.fonts.monospace.package
      config.stylix.fonts.serif.package
      config.stylix.fonts.sansSerif.package
      config.stylix.fonts.emoji.package
    ];

}
