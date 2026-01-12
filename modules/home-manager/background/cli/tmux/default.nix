{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # ./catppuccin.nix
    #./pomodoro.nix
  ];

  programs.tmux =
    let
      cfg = config.programs.tmux;
    in
    {
      enable = true;
      # package = pkgs.unstable.tmux;
      clock24 = true;
      shortcut = "Space";
      keyMode = "vi";
      mouse = true;
      terminal = "tmux-256color";
      baseIndex = 1;
      customPaneNavigationAndResize = true;
      resizeAmount = 5;
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
        # catppuccin
        {
          plugin = cpu;
          extraConfig = ''
            set -g status-left ""
            set -g status-right "[#S] |  #{cpu_percentage} |  #{ram_percentage} |  %H:%M "
            set -g status-right-length 40
          '';
        }
        yank
        vim-tmux-navigator
      ];
      extraConfig =
        let
          japanese-numbers = false;
          numbers =
            if japanese-numbers then
              "#(echo '#I' | sed 's/0/〇/g;s/1/一/g;s/2/二/g;s/3/三/g;s/4/四/g;s/5/五/g;s/6/六/g;s/7/七/g;s/8/八/g;s/9/九/g')"
            else
              "#I";
        in
        (lib.optionalString (cfg.terminal == "tmux-256color") ''
          # https://stackoverflow.com/questions/41783367/tmux-tmux-true-color-is-not-working-properly/41786092#41786092
          # set-option -sa terminal-overrides ",xterm*:Tc"
          set -asg terminal-features ",tmux-256color:256:RGB:mouse:cstyle"
        '')
        + ''
          # Make TMUX work with yazi
          set -g allow-passthrough on
          set -ga update-environment TERM
          set -ga update-environment TERM_PROGRAM

          # set -g status-right "#{pomodoro_status}"

          # Move bar to top
          set-option -g status-position top

          # Renumber windows if one is closed
          set-option -g renumber-windows on

          # Create some space between bar and rest
          # setw -g pane-border-status top
          # setw -g pane-border-format '-'

          # resize like vim
          # bind -r h resize-pane -L 5
          # bind -r j resize-pane -D 5
          # bind -r k resize-pane -U 5
          # bind -r l resize-pane -R 5

          # maximize pane
          bind -r m resize-pane -Z

          # reload config
          bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

          # Set copy command
          set -s copy-command 'wl-copy'
          # select and copy like in vim
          bind-key -T copy-mode-vi 'v' send -X begin-selection
          bind-key -T copy-mode-vi 'y' send -X copy-selection

          unbind -T copy-mode-vi MouseDragEnd1Pane

          # move window to the left & right
          bind-key -r < swap-window -t -1
          bind-key -r > swap-window -t +1

          # Status bar

          set -g status-style bg=default,fg=black,bright

          set -g window-status-format " ${numbers}:#W "
          set -g window-status-current-format " ${numbers}:#W "
        '';
      # + (
      #   let
      #     inherit (config.lib.stylix.colors) withHashtag;
      #   in
      #   ''
      #     set -g @catppuccin_window_status_style "rounded"
      #     set -ogq @thm_bg "${withHashtag.base00}"
      #     set -ogq @thm_fg "${withHashtag.base05}"
      #   ''
      # );
    };
}
