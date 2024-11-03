{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}@args:
{
  options.nushell.enable = lib.mkEnableOption "Configure nushell for you";

  config = lib.mkIf config.nushell.enable {
    programs = {
      nushell = {
        enable = true;
        package = pkgs.unstable.nushell;
        shellAliases = {
          grep = "rg";
          # tss = "tailscale switch (tailscale switch --list | tail -n +2 | fzf | tr -s ' ' | cut -d ' ' -f1)";
          # tsr = ''bash -c "sudo systemctl restart tailscaled.service"'';
          #tsen = "tailscale status | grep 'offers exit node' | fzf | tr -s ' ' | cut -d' ' -f2";
        };
        environmentVariables = {
          # PATH = "$env.PATH | append ($env.HOME + '/.bin')";
          TEST = "1234";
          LS_COLORS = "(vivid generate gruvbox-dark)";
        };

        configFile.text =
          ''
            # Common ls aliases and sort them by type and then name
            def lla [...args] { ls -la ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
            def la  [...args] { ls -a  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
            def ll  [...args] { ls -l  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
            def l   [...args] { ls     ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
            # Tailscale Switch
            def tss [] { tailscale switch --list | detect columns | sk --format {get Tailnet Account | str join " "} --preview {} | get ID | tailscale switch $in }

            # Completions
            # mainly pieced together from https://www.nushell.sh/cookbook/external_completers.html

            # carapce completions https://www.nushell.sh/cookbook/external_completers.html#carapace-completer
            # + fix https://www.nushell.sh/cookbook/external_completers.html#err-unknown-shorthand-flag-using-carapace
            # enable the package and integration bellow
            $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
            let carapace_completer = { |spans: list<string>|
              carapace $spans.0 nushell ...$spans
              | from json
              | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
            }

            # fish completions https://www.nushell.sh/cookbook/external_completers.html#fish-completer
            let fish_completer = { |spans|
              ${lib.getExe pkgs.fish} --command $'complete "--do-complete=($spans | str join " ")"'
              | $"value(char tab)description(char newline)" + $in
              | from tsv --flexible --no-infer
            }

            # zoxide completions https://www.nushell.sh/cookbook/external_completers.html#zoxide-completer
            let zoxide_completer = { |spans|
                $spans | skip 1 | zoxide query -l ...$in | lines
                | where { |x| $x != $env.PWD }
                | if ($in | default [] | is-empty) { $env.PWD } else { $in }
                | each { |x| $x + '/' }
            }

            # multiple completions
            # the default will be carapace, but you can also switch to fish
            # https://www.nushell.sh/cookbook/external_completers.html#alias-completions
            let multiple_completers = { |spans|
              ## alias fixer start https://www.nushell.sh/cookbook/external_completers.html#alias-completions
              let expanded_alias = scope aliases
              | where name == $spans.0
              | get -i 0.expansion

              let spans = if $expanded_alias != null {
                $spans
                | skip 1
                | prepend ($expanded_alias | split row ' ' | take 1)
              } else {
                $spans
              }
              ## alias fixer end

              match $spans.0 {
                __zoxide_z | __zoxide_zi => $zoxide_completer
                _ => $carapace_completer
                # _ => $fish_completer
              } | do $in $spans
            }

            $env.config = {
              show_banner: false,
              edit_mode: vi
              keybindings: [
                {
                  name: delete_line
                  modifier: control
                  keycode: char_u
                  mode: [emacs, vi_normal, vi_insert]
                  event: { edit: clear }
                }
              ]
              completions: {
                case_sensitive: false # case-sensitive completions
                quick: true           # set to false to prevent auto-selecting completions
                partial: true         # set to false to prevent partial filling of the prompt
                algorithm: "fuzzy"    # prefix or fuzzy
                external: {
                  # set to false to prevent nushell looking into $env.PATH to find more suggestions
                  enable: true
                  # set to lower can improve completion performance at the cost of omitting some options
                  max_results: 100
                  completer: $multiple_completers
                }
              }
            }
          ''
          + lib.optionalString config.skim.enable ''
            plugin add ${lib.getExe pkgs.unstable.nushellPlugins.skim}
          ''
          + (
            let
              path = osConfig.services.ssh-tpm-agent.userProxyPath;
            in
            lib.optionalString ((args ? nixosConfig) && (path != "")) ''
              $env.SSH_AUTH_SOCK = ($env.XDG_RUNTIME_DIR + '/ssh-tpm-agent.sock')
            ''
          );
      };
    };

    home.packages = lib.mkIf config.skim.enable [ pkgs.unstable.nushellPlugins.skim ];
  };
}
