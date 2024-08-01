{ pkgs, ... }:
let
  catppuccin-alacritty = builtins.fetchGit {
    url = "https://github.com/catppuccin/alacritty";
    ref = "refs/tags/yaml";
  };
  catppuccin-warp = builtins.fetchGit {
    url = "https://github.com/catppuccin/warp"; 
    ref = "main";
  };
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      import = [
        "~/.config/alacritty/catppuccin/catppuccin-macchiato.yml"
      ];
      shell = {
        program = "zsh";
        #args = [
        #  "-l"
        #  "-c"
        #  "tmux attach || tmux"
        #];
      };
      window = {
        decorations = "full";
	      dimensions = {
	        columns = 108;
	        lines = 36;
	      };
        opacity = 1;
      };
      font = {
        size = 12;
        offset = {
          y = 0;
          x = 0;
        };
        glyph_offset = {
          y = 0;
          x = 0;
        };
        bold = {
          style  = "Bold";
          family = "FiraCode Nerd Font";
        };
        normal = {
          style  = "Regular";
          family = "FiraCode Nerd Font";
        };
      };
    };
  };

  # Theme for alacritty
  home.file.".config/alacritty/catppuccin/catppuccin-macchiato.yml".source = "${catppuccin-alacritty}/catppuccin-macchiato.yml";

  # Theme for Warp
  home.file.".local/share/warp-terminal/themes/catppuccin" = {
    recursive = true;
    source = "${catppuccin-warp}/dist";
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    shortcut = "Space";
    plugins = with pkgs; [
      tmuxPlugins.catppuccin
      tmuxPlugins.yank
      tmuxPlugins.vim-tmux-navigator
    ];
    extraConfig = ''
      set -g default-terminal "screen-256color"
      set-option -ga terminal-overrides ",alacritty:RGB"
      set -g @catppuccin_flavour "macchiato"

      # Enable mouse support 
      set -g mouse on
    '';
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}
      config.enable_wayland = false
      config.color_scheme = 'Catppuccin Macchiato'
      config.hide_tab_bar_if_only_one_tab = true
      config.window_decorations = 'TITLE | RESIZE'
      config.window_frame = {
        active_titlebar_bg = '#24273a',
        inactive_titlebar_bg = '#24273a',
        -- Colors
        border_left_width = '0.5cell',
        border_right_width = '0.5cell',
        border_bottom_height = '0.25cell',
        -- border_top_height = '0.25cell',
        border_left_color = '#181926',
        border_right_color = '#181926',
        border_bottom_color = '#181926',
        -- border_top_color = '#181926',
      }
      config.window_background_opacity = 0.99
      -- config.win32_system_backdrop = 'Acrylic'
      -- config.macos_window_background_blur = 20
      config.initial_rows = 36
      config.initial_cols = 108
      config.font = wezterm.font_with_fallback {
        'Fira Code',
        'FiraCode Nerd Font',
      }
      return config
    '';
  };
}
