# Additions to the upstream programs.herdr module (./upstream.nix, dropped once
# home-manager ships it). Nothing here may *declare* an option upstream owns —
# enable/package/settings are only read, never redeclared, so this file keeps
# working unchanged when the import above it flips to the real upstream module.
{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    optionalString
    ;

  cfg = config.programs.herdr;

  herdr = if cfg.package == null then "herdr" else lib.getExe cfg.package;
in
{
  options.programs.herdr = {
    autoAttach = mkOption {
      type = types.bool;
      default = false;
      description = ''
        When true, auto-attach to herdr in every interactive shell.
        When false (default), only auto-attach over SSH (checks SSH_TTY).
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        [ui]
        pane_borders = false
      '';
      description = ''
        Extra TOML merged into {option}`programs.herdr.settings`.

        Parsed with `builtins.fromTOML` at evaluation time, so syntax errors
        surface during the build rather than when herdr starts.

        This becomes an ordinary definition of {option}`programs.herdr.settings`
        and follows the module system's merge rules, exactly like the settings
        set in ./default.nix and ./theme.nix: tables merge key by key, arrays
        of tables (`[[keys.command]]`) are concatenated in unspecified order,
        and redefining a scalar that is already set elsewhere is an evaluation
        error naming the conflicting path rather than a silent override.
      '';
    };

    # Default from home.shell.enable<Shell>Integration rather than a bare
    # mkEnableOption, so the shells this host actually configures decide.
    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    programs.herdr.settings = fromTOML cfg.extraConfig;

    # herdr is one headless server hosting N named sessions, so `herdr status`
    # asks "is the server up?" — auto-attach deliberately joins a running server
    # and never spawns one, which keeps a client from starting a server whose
    # protocol version it may not match.
    programs = {
      zsh.initContent = mkIf cfg.enableZshIntegration (
        # Runs early: the snippet execs, so there is no point paying for the
        # rest of zshrc first.
        lib.mkOrder 200 ''
          # herdr auto-attach
          if [[ -z "$HERDR_NO_AUTO_ATTACH" && -z "$__HERDR_AUTO_ATTACHED" && -z "$HERDR_SOCKET_PATH" && ${
            optionalString (!cfg.autoAttach) ''-n "$SSH_TTY" && ''
          }-o interactive && "$TERM" != "dumb" ]]; then
            if ${herdr} status >/dev/null 2>&1; then
              export __HERDR_AUTO_ATTACHED=1
              exec ${herdr}
            fi
          fi
        ''
      );

      fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
        # herdr auto-attach
        if not set -q HERDR_NO_AUTO_ATTACH; and not set -q __HERDR_AUTO_ATTACHED; and not set -q HERDR_SOCKET_PATH; ${
          optionalString (!cfg.autoAttach) "and set -q SSH_TTY; "
        }and status is-interactive; and test "$TERM" != dumb
          if ${herdr} status >/dev/null 2>&1
            set -gx __HERDR_AUTO_ATTACHED 1
            exec ${herdr}
          end
        end
      '';

      bash.initExtra = mkIf cfg.enableBashIntegration ''
        # herdr auto-attach
        if [[ -z "$HERDR_NO_AUTO_ATTACH" && -z "$__HERDR_AUTO_ATTACHED" && -z "$HERDR_SOCKET_PATH" && ${
          optionalString (!cfg.autoAttach) ''-n "$SSH_TTY" && ''
        }"$-" == *i* && "$TERM" != "dumb" ]]; then
          if ${herdr} status >/dev/null 2>&1; then
            export __HERDR_AUTO_ATTACHED=1
            exec ${herdr}
          fi
        fi
      '';
    };
  };
}
