{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.libreoffice.enable = lib.mkEnableOption "Enable the document suite LibreOffice";

  config = lib.mkIf config.libreoffice.enable {
    home.packages =
      (with pkgs.unstable; [
        libreoffice-fresh
      ])
      ++ (with pkgs; [
        # libreoffice-qt
        hunspell
        hunspellDicts.en-us
        hunspellDicts.en-gb-ise
        hunspellDicts.de-de
      ]);
  };
}
