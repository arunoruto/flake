{
  config,
  osConfig,
  # lib,
  # pkgs,
  # inputs,
  ...
}@args:
{
  programs.wezterm = {
    enableZshIntegration = config.programs.zsh.enable;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}
      config.audible_bell = "Disabled"
      config.enable_wayland = false
      -- config.front_end = "WebGpu"
      -- config.enable_wayland = true
      config.front_end = "${
        # if ((args ? nixosConfig) && (!osConfig.hosts.nvidia.enable)) then "OpenGL" else "WebGpu"
        if ((args ? nixosConfig) && (osConfig.networking.hostName == "madara")) then "OpenGL" else "WebGpu"
      }"
      config.hide_tab_bar_if_only_one_tab = true
      -- config.window_decorations = 'TITLE | RESIZE'
      config.window_decorations = 'RESIZE'
      config.initial_rows = ${builtins.toString config.terminals.height}
      config.initial_cols = ${builtins.toString config.terminals.width}
      config.warn_about_missing_glyphs = false
      return config
    '';
  };
  # // lib.optionalAttrs (args ? nixosConfig) {
  #   package =
  #     if osConfig.hosts.nvidia.enable then
  #       inputs.wezterm.packages.${pkgs.system}.default
  #     else
  #       pkgs.wezterm;
  # };
}
