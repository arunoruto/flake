{
  config,
  pkgs,
  lib,
  ...
}:
let
  # shaders = pkgs.fetchFromGitHub {
  #   owner = "0xhckr";
  #   repo = "ghostty-shaders";
  #   rev = "01738211b26a60eac33119d6da0c7bb12763e683";
  #   hash = "sha256-5c3WBG3Litw/ayLI6mlCoGw+EIHrj3vkgc4j8+4K0OY=";
  # };
  custom-config = "config-custom";
  isDarwin = pkgs.stdenv.isDarwin;

  # On Darwin, ghostty from nixpkgs doesn't work, so we use a fake package
  # Users should install Ghostty manually via the official installer
  ghosttyPackage =
    if isDarwin then
      pkgs.runCommand "ghostty-placeholder" {
        meta.mainProgram = "ghostty";
      } "mkdir -p $out/bin && touch $out/bin/ghostty"
    else
      pkgs.unstable.ghostty;
in
{
  programs.ghostty = {
    package = ghosttyPackage;

    enableBashIntegration = lib.mkDefault true;
    enableFishIntegration = lib.mkDefault config.programs.fish.enable;
    enableZshIntegration = lib.mkDefault config.programs.zsh.enable;

    settings = {
      window-height = config.terminals.height;
      window-width = config.terminals.width;
      keybind = [
        # "global:ctrl+backquote=toggle_quick_terminal"
        "alt+enter=toggle_fullscreen"
        "alt+h=previous_tab"
        "alt+l=next_tab"
      ];
      config-file = "${custom-config}";
      # custom-shader = "${shaders}/bloom.glsl";

      background-blur = 20;
      macos-option-as-alt = "left";
    };
  };

  # On Darwin, the bat syntax file doesn't exist in our placeholder package
  # So we disable it to prevent activation errors
  xdg.configFile."bat/syntaxes/ghostty.sublime-syntax" = lib.mkIf isDarwin {
    enable = false;
  };

  xdg.configFile = {
    "ghostty/${custom-config}".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/flake/modules/home-manager/foreground/terminal/ghostty/${custom-config}";
  };
}
