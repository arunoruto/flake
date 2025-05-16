{
  config,
  pkgs,
  lib,
  ...
}:
{

  programs.ghostty = {
    package = pkgs.unstable.ghostty;

    enableBashIntegration = lib.mkDefault true;
    enableFishIntegration = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;

    settings = {
      # background-blur-radius = 20;
      background-blur = 20;
      window-height = config.terminals.height;
      window-width = config.terminals.width;
      keybind = [
        "alt+enter=toggle_fullscreen"
        "alt+h=previous_tab"
        "alt+l=next_tab"
      ];
    };
  };
}
