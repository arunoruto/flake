{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.gui.packages.enable = lib.mkEnableOption "Setup amd tools";

  config = lib.mkIf config.gui.packages.enable {
    environment.systemPackages = with pkgs; [
      vlc
      unstable.vscode
      # wezterm

      discord
      gthumb
      # jabref
      libsForQt5.kdenlive
      libsForQt5.okular
      #mailspring
      # masterpdfeditor
      # mprime
      # unstable.mqtt-explorer
      unstable.plex-desktop
      remmina
      zoom-us
      zotero
    ];
  };
}
