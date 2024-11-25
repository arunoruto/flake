{ pkgs, ... }:
{
  imports = [
    # ./catppuccin.nix
    #./pomodoro.nix
  ];

  programs.tmux = {
    enable = true;
    # package = pkgs.unstable.tmux;
    clock24 = true;
    shortcut = "Space";
    terminal = "screen-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    plugins = with pkgs.tmuxPlugins; [
      #   {
      #     plugin = tmuxPlugins.continuum;
      #     extraConfig = ''
      #       set -g @continuum-restore 'on'
      #       set -g @continuum-save-interval '30' # minutes
      #     '';
      #   }
      #   {
      #     plugin = tmuxPlugins.resurrect;
      #     extraConfig = ''
      #       set -g @resurrect-strategy-nvim 'session'
      #       set -g @resurrect-capture-pane-contents 'on'
      #     '';
      #   }
      yank
      vim-tmux-navigator
    ];
    extraConfig = ''
      # Make TMUX work with yazi
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # set -g status-right "#{pomodoro_status}"
      # https://stackoverflow.com/questions/41783367/tmux-tmux-true-color-is-not-working-properly/41786092#41786092
      set -g default-terminal "tmux-256color"
      set-option -sa terminal-overrides ",xterm*:Tc"

      # Move bar to top
      set-option -g status-position top

      # Renumber windows if one is closed
      set-option -g renumber-windows on

      # Create some space between bar and rest
      # setw -g pane-border-status top
      # setw -g pane-border-format '-'

      # resize like vim
      bind -r h resize-pane -L 5
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5

      # maximize pane
      bind -r m resize-pane -Z

      # Set copy command
      set -s copy-command 'wl-copy'
      # select and copy like in vim
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };
}
