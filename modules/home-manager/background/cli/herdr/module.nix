{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    optional
    optionalString
    ;

  cfg = config.programs.herdr;
  settingsFormat = pkgs.formats.toml { };

  configFile = pkgs.runCommand "herdr-config.toml" { } ''
    cp ${settingsFormat.generate "herdr-config.toml" cfg.settings} $out
    ${optionalString (cfg.extraConfig != "") ''
      echo >> $out
      cat ${pkgs.writeText "herdr-extra-config.toml" cfg.extraConfig} >> $out
    ''}
  '';
in
{
  options.programs.herdr = {
    enable = mkEnableOption "herdr";

    package = mkPackageOption pkgs "herdr" { nullable = true; };

    autoAttach = mkOption {
      type = types.bool;
      default = false;
      description = ''
        When true, auto-attach to herdr in every interactive shell.
        When false (default), only auto-attach over SSH (checks SSH_TTY).
      '';
    };

    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };
      description = ''
        Settings for herdr config.toml.

        See <https://herdr.dev/docs/configuration/> for all options.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra TOML appended to the herdr config.toml.";
    };

    enableZshIntegration = mkEnableOption "zsh integration for auto-attaching to herdr";

    enableFishIntegration = mkEnableOption "fish integration for auto-attaching to herdr";

    enableBashIntegration = mkEnableOption "bash integration for auto-attaching to herdr";
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;

    xdg.configFile = mkIf (cfg.settings != { } || cfg.extraConfig != "") {
      "herdr/config.toml".source = configFile;
    };

    programs.zsh.initContent = mkIf cfg.enableZshIntegration ''
      # herdr auto-attach
      if [[ -z "$__HERDR_AUTO_ATTACHED" && -z "$HERDR_SOCKET_PATH" && ${optionalString (!cfg.autoAttach) ''-n "$SSH_TTY" && ''}-o interactive && "$TERM" != "dumb" ]]; then
        export __HERDR_AUTO_ATTACHED=1
        exec herdr
      fi
    '';

    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
      # herdr auto-attach
      if not set -q __HERDR_AUTO_ATTACHED; and not set -q HERDR_SOCKET_PATH; ${optionalString (!cfg.autoAttach) "and set -q SSH_TTY; "}and status is-interactive; and test "$TERM" != dumb
        set -gx __HERDR_AUTO_ATTACHED 1
        exec herdr
      end
    '';

    programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
      # herdr auto-attach
      if [[ -z "$__HERDR_AUTO_ATTACHED" && -z "$HERDR_SOCKET_PATH" && ${optionalString (!cfg.autoAttach) ''-n "$SSH_TTY" && ''}"$-" == *i* && "$TERM" != "dumb" ]]; then
        export __HERDR_AUTO_ATTACHED=1
        exec herdr
      fi
    '';
  };
}
