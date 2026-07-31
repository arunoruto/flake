{
  config,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
{
  imports = [
    # Drop at home-manager 26.11 — upstream ships modules/programs/herdr.nix.
    ./upstream.nix
    ./module.nix
    ./theme.nix
  ];

  config = {
    programs.herdr = lib.mkIf config.programs.herdr.enable {
      package =
        if ((osConfig != null) && (osConfig.networking.hostName == "madara")) then
          pkgs.custom.herdr
        else
          pkgs.unstable.herdr;
      # package = pkgs.unstable.herdr;

      settings = {
        onboarding = false;

        terminal.default_shell = config.shell.main;

        update.version_check = false;

        ui = {
          mouse_capture = true;
          pane_borders = true;
          pane_gaps = true;
          confirm_close = true;
          sidebar_width = 32;
          sound.enabled = false;
        };

        # tmux-like keybindings. Mirrors the tmux config in
        # ../tmux/default.nix: C-Space prefix, vi-style pane focus
        # (customPaneNavigationAndResize), and the custom r/m binds.
        keys = {
          # tmux: shortcut = "Space" -> C-Space prefix
          prefix = "ctrl+space";

          # prefix+q (herdr default) reads like "quit"; tmux's prefix+d for
          # detach is clearer and what the fingers already know.
          detach = "prefix+d";
          toggle_sidebar = "prefix+b";

          # Workspaces, goto, and sidebar navigate-mode are herdr-only and
          # have no tmux analogue, so they stay at their defaults:
          #   prefix+w workspace picker   prefix+g goto
          #   prefix+shift+n new workspace   h/j/k/l + arrows navigate mode

          # windows -> tabs
          new_tab = "prefix+c"; # tmux: prefix c
          next_tab = "prefix+n"; # tmux: prefix n (== herdr default)
          previous_tab = "prefix+p"; # tmux: prefix p (== herdr default)
          switch_tab = "prefix+1..9"; # tmux: prefix 1..9
          # Bind both the tmux key and herdr's tab-consistent default.
          rename_tab = [
            "prefix+comma" # tmux: prefix ,
            "prefix+shift+t" # herdr default
          ];
          close_tab = [
            "prefix+ampersand" # tmux: prefix &
            "prefix+shift+x" # herdr default (pairs with close_pane)
          ];

          # panes
          # tmux splits are % (side-by-side) and " (stacked); neither is a
          # bindable key in herdr, so keep herdr's v / minus.
          split_vertical = "prefix+v";
          split_horizontal = "prefix+minus";
          close_pane = "prefix+x"; # tmux: prefix x
          copy_mode = "prefix+["; # tmux: prefix [
          cycle_pane_next = [
            "prefix+o" # tmux: prefix o
            "prefix+tab" # herdr default
          ];
          # tmux maximizes a pane with `m` and zooms with `z`.
          zoom = [
            "prefix+z"
            "prefix+m"
          ];
          resize = "prefix+r";
          command = [
            {
              key = "prefix+shift+r";
              type = "shell";
              command = "herdr server reload-config";
              description = "reload herdr config";
            }
          ];
        };

        session.resume_agents_on_restore = true;
      };
    };

    # Session switcher. herdr has no in-app session manager and blocks
    # nested launches, so switching is detach (prefix+d) -> relaunch from
    # the shell. `hs` makes that one step:
    #   hs <name>  jump straight to (or create) that session
    #   hs         fuzzy-pick an existing one, or type a fresh name + Enter
    #              to create one (fzf --print-query echoes the typed text
    #              when nothing matches). Esc cancels without creating.
    # To force a brand-new name that is a substring of an existing one
    # (e.g. "wo" when "work" exists), use the arg form: `hs wo`.
    # `hsl` just lists them.
    programs.fish = lib.mkIf config.programs.herdr.enableFishIntegration {
      shellAbbrs.hsl = "herdr session list";
      functions.hs = {
        description = "switch to or create a herdr session";
        body = ''
          if test -n "$argv[1]"
              herdr --session $argv[1]
              return
          end

          set -l names (herdr session list --json | ${pkgs.jq}/bin/jq -r '.sessions[].name')

          # fzf is the middle stage of the pipe; read its output line by
          # line so $pipestatus survives to tell abort (130) from select.
          set -l lines
          printf '%s\n' $names \
              | ${pkgs.fzf}/bin/fzf --print-query --reverse --height 40% \
                  --prompt 'herdr session> ' \
              | while read -l line
                  set -a lines $line
              end
          # Capture immediately: the next command resets $pipestatus.
          set -l code $pipestatus[2]
          test $code -eq 130; and return # Esc / Ctrl-C -> cancel

          # On a match fzf appends it after the query line; with no match
          # only the typed query prints -> create that session.
          set -l target ""
          set -q lines[1]; and set target $lines[-1]
          test -n "$target"; and herdr --session $target
        '';
      };
    };
  };
}
