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
    enableFishIntegration = lib.mkDefault config.programs.fish.enable;
    enableZshIntegration = lib.mkDefault config.programs.zsh.enable;

    settings = {
      background-blur = 20;
      window-height = config.terminals.height;
      window-width = config.terminals.width;
      keybind = [
        # "global:ctrl+backquote=toggle_quick_terminal"
        "alt+enter=toggle_fullscreen"
        "alt+h=previous_tab"
        "alt+l=next_tab"
      ];
    };
  };
}
