{pkgs, ...}: let
  tmux-catpuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "2024-05-12";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "697087f593dae0163e01becf483b192894e69e33";
      sha256 = "sha256-EHinWa6Zbpumu+ciwcMo6JIIvYFfWWEKH1lwfyZUNTo=";
    };
  };
in {
  programs.tmux = {
    plugins = with pkgs; [
      {
        # plugin = tmuxPlugins.catppuccin;
        plugin = tmux-catpuccin;
        extraConfig = ''
          #set -g @catppuccin_flavour "macchiato"
          set -g @catppuccin_custom_plugin_dir "~/.tmux/plugins/tmux/custom"

          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator "█ "
          set -g @catppuccin_window_number_position "left"

          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"

          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W"

          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator ""
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_status_modules_right "session"
          # set -g @catppuccin_status_modules_right "pomodoro session"
        '';
      }
    ];
  };
}
