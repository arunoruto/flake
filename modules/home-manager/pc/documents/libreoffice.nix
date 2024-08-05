{pkgs, ...}: {
  home.packges = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en-us
    hunspellDicts.en-gb-ise
    hunspellDicts.de-de
  ];
}
