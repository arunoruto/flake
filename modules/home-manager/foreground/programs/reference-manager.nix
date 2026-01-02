{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.reference-manager.enable = lib.mkEnableOption "Reference manager(s)";

  config = lib.mkIf config.programs.reference-manager.enable {
    home.packages = with pkgs; [
      paperlib
      (makeDesktopItem {
        name = "paperlib";
        desktopName = "PaperLib";
        exec = "paperlib";
        icon = ../../../../overlays/paperlib.png;
        categories = [ "Utility" ];
        terminal = false;
      })
      # jabref
    ];
  };

}
