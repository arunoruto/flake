{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.packages.enable = lib.mkEnableOption "Setup packages";

  config = lib.mkIf config.programs.packages.enable {
    environment.systemPackages = with pkgs; [
      # vlc
      # # wezterm

      # discord
      # gthumb
      # # libsForQt5.kdenlive
      # libsForQt5.okular
      # #mailspring
      # # masterpdfeditor
      # # mprime
      # # unstable.mqtt-explorer
      # unstable.plex-desktop
      # remmina
      # zoom-us
      # zotero
    ];
  };
}
