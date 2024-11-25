{
  config,
  lib,
  ...
}:
{
  options.wezterm.enable = lib.mkEnableOption "Enable wezterm terminal";

  config = lib.mkIf config.wezterm.enable {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = {}
        config.audible_bell = "Disabled"
        config.enable_wayland = false
        config.front_end = "WebGpu"
        -- config.front_end = "OpenGL"
        config.hide_tab_bar_if_only_one_tab = true
        -- config.window_decorations = 'TITLE | RESIZE'
        config.window_decorations = 'RESIZE'
        config.initial_rows = 36
        config.initial_cols = 108
        config.warn_about_missing_glyphs = false
        return config
      '';
    };
  };
}
