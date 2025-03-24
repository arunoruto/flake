{
  # config,
  # lib,
  pkgs,
  ...
}:
{
  programs.google-chrome = {
    package = pkgs.google-chrome;
    commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform" ];
    # dictionaries = with pkgs.hunspellDictsChromium; [
    #   en_US
    #   de_DE
    # ];
  };
}
