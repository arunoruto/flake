{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.fish.enable = lib.mkEnableOption "Configure fish for you";

  config = lib.mkIf config.fish.enable {
    programs = {
      fish = {
        enable = true;
        package = pkgs.unstable.fish;
        shellAliases = {
          grep = "rg";
          tss = "tailscale switch $(tailscale switch --list | tail -n +2 | fzf | tr -s ' ' | cut -d ' ' -f1)";
          fish-bench = ''${lib.getExe pkgs.hyperfine} --warmup 3 "fish -i -c exit"'';
        };
        interactiveShellInit = ''
          # Disable greeting
          set fish_greeting

          set -gx LS_COLORS $(vivid generate gruvbox-dark)
          set -gx NIX_LD_LIBRARY_PATH /run/current-system/sw/share/nix-ld/lib
          set -gx COPILOT_API_KEY $(cat ${config.sops.secrets."tokens/copilot".path})
        '';

        functions = {
          bind_bang.body = ''
            switch (commandline --current-token)[-1]
              case "!"
                  # Without the `--`, the functionality can break when completing
                  # flags used in the history (since, in certain edge cases
                  # `commandline` will assume that *it* should try to interpret
                  # the flag)
                  commandline --current-token -- $history[1]
                  commandline --function repaint
              case "*"
                  commandline --insert !
            end
          '';

          bind_dollar.body = ''
            switch (commandline --current-token)[-1]
              # This case lets us still type a literal `!$` if we need to (by
              # typing `!\$`). Probably overkill.
              case "*!\\"
                  # Without the `--`, the functionality can break when completing
                  # flags used in the history (since, in certain edge cases
                  # `commandline` will assume that *it* should try to interpret
                  # the flag)
                  commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
                  commandline --insert '$'
              case "!"
                  commandline --current-token ""
                  commandline --function history-token-search-backward


              # Main difference from referenced version is this `*!` case
              # =========================================================
              #
              # If the `!$` is preceded by any text, search backward for tokens
              # that contain that text as a substring. E.g., if we'd previously
              # run
              #
              #   git checkout -b a_feature_branch
              #   git checkout master
              #
              # then the `fea!$` in the following would be replaced with
              # `a_feature_branch`
              #
              #   git branch -d fea!$
              #
              # and our command line would look like
              #
              #   git branch -d a_feature_branch
              #
              case "*!"
                  # Without the `--`, the functionality can break when completing
                  # flags used in the history (since, in certain edge cases
                  # `commandline` will assume that *it* should try to interpret
                  # the flag)
                  commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
                  commandline --function history-token-search-backward
              case "*"
                  commandline --insert '$'
            end
          '';

          fish_user_key_bindings.body = ''
            bind ! bind_bang
            bind '$' bind_dollar
          '';
        };

        # configFile.text = '''';
      };
    };
  };
}
