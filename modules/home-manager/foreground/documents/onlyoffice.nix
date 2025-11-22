{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.onlyoffice.enable = lib.mkEnableOption "Enable the document suite OnlyOffice";

  config = lib.mkIf config.programs.onlyoffice.enable {
    home.packages =
      (with pkgs.unstable; [
        onlyoffice-desktopeditors
      ])
      ++ (with pkgs; [
        # libreoffice-qt
        # hunspell
        # hunspellDicts.en-us
        # hunspellDicts.en-gb-ise
        # hunspellDicts.de-de
        # hyphenDicts.de-de
        # hyphenDicts.en-us
      ]);
  };
}
