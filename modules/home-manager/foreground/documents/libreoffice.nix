{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.libreoffice.enable = lib.mkEnableOption "Enable the document suite LibreOffice";

  config = lib.mkIf config.programs.libreoffice.enable {
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
        hyphenDicts.de-de
        hyphenDicts.en-us
      ]);
  };
}
