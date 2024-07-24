{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}
      config.audible_bell = "Disabled"
      config.enable_wayland = false
      config.hide_tab_bar_if_only_one_tab = true
      -- config.color_scheme = 'Catppuccin Macchiato'
      -- config.color_scheme = 'stylix'
      -- config.window_decorations = 'TITLE | RESIZE'
      config.window_decorations = 'RESIZE'
      -- config.window_frame = {
      --   active_titlebar_bg = '#24273a',
      --   inactive_titlebar_bg = '#24273a',
      --   -- Colors
      --   border_left_width = '0.5cell',
      --   border_right_width = '0.5cell',
      --   border_bottom_height = '0.25cell',
      --   -- border_top_height = '0.25cell',
      --   border_left_color = '#181926',
      --   border_right_color = '#181926',
      --   border_bottom_color = '#181926',
      --   -- border_top_color = '#181926',
      -- }
      -- config.window_background_opacity = 0.99
      -- config.win32_system_backdrop = 'Acrylic'
      -- config.macos_window_background_blur = 20
      -- config.font = wezterm.font_with_fallback {
      --   'FiraCode Nerd Font',
      --   'JetBrains Mono',
      --   'Noto Color Emoji',
      -- }
      config.initial_rows = 36
      config.initial_cols = 108
      config.warn_about_missing_glyphs = false
      return config
    '';
  };
}
