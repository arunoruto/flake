{
  config,
  lib,
  pkgs,
  ...
}:
let
  yaml = pkgs.formats.yaml { };
in
with lib;
{
  meta.maintainers = with maintainers; [ arunoruto ];

  options.programs.vivid = {
    enable = mkEnableOption ''
      vivid - A themeable LS_COLORS generator with a rich filetype datebase
      <link xlink:href="https://github.com/sharkdp/vivid" />
    '';

    package = mkPackageOption pkgs "vivid" { };

    # enableBashIntegration = mkOption {
    #   default = true;
    #   type = types.bool;
    #   description = ''
    #     Whether to enable Bash integration.
    #     Adds LS_COLORS to Bash.
    #   '';
    # };

    # enableFishIntegration = mkOption {
    #   default = true;
    #   type = types.bool;
    #   description = ''
    #     Whether to enable Fish integration.
    #     Adds LS_COLORS to Fish.
    #   '';
    # };

    # enableNushellIntegration = mkOption {
    #   default = true;
    #   type = types.bool;
    #   description = ''
    #     Whether to enable Nushell integration.
    #     Adds LS_COLORS to Nushell.
    #   '';
    # };

    # enableZshIntegration = mkOption {
    #   default = true;
    #   type = types.bool;
    #   description = ''
    #     Whether to enable Zsh integration.
    #     Adds LS_COLORS to Zsh.
    #   '';
    # };

    theme = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "molokai";
      description = ''
        Color theme to enable.
        Run `vivid themes` for a list of available themes.
      '';
    };

    filetypes = mkOption {
      type = yaml.type;
      default = { };
      example = literalExpression ''
        {
          core = {
            regular_file = [ "$fi" ];
            directory = [ "$di" ];
          };
          text = {
            readme = [ "README.md" ];
            licenses = [ "LICENSE" ];
          };
        }
      '';
      description = ''
        Configuration written to
        <filename>~/.config/vivid/filetypes.yml</filename>.
        Visit <link xlink:href="https://github.com/sharkdp/vivid/tree/master/config/filetypes.yml" />
        for a reference file.
      '';
    };

    themes = mkOption {
      type = types.attrsOf (yaml.type);
      default = { };
      example = literalExpression ''
        {
          mytheme = {
            colors = {
              blue = "0000ff";
            };
            core = {
              directory = {
                foreground = "blue";
                font-style = "bold";
              };
            };
          };
        }
      '';
      description = ''
        Theme files written to
        <filename>~/.config/vivid/themes/<mytheme>.yml</filename>.
        Visit <link xlink:href="https://github.com/sharkdp/vivid/tree/master/themes" />
        for references.
      '';
    };
  };

  config =
    let
      cfg = config.programs.vivid;
      lsColors = builtins.readFile (
        pkgs.runCommand "vivid-ls-colors" { } ''
          ${lib.getExe cfg.package} generate ${cfg.theme} > $out
        ''
      );
    in
    # bin = lib.getExe cfg.package;
    # bashLine = theme: ''export LS_COLORS="$(${bin} generate ${theme})"'';
    # fishLine = theme: "set -gx LS_COLORS (${bin} generate ${theme})";
    # nushellLine = theme: "${bin} generate ${theme}";
    # zshLine = bashLine;
    mkIf cfg.enable {
      home = {
        packages = [ cfg.package ];
        sessionVariables.LS_COLORS = "${lsColors}";
      };

      # programs.bash.initExtra = mkIf cfg.enableBashIntegration (bashLine cfg.theme);
      # programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration (fishLine cfg.theme);
      # programs.nushell.environmentVariables.LS_COLORS = mkIf cfg.enableNushellIntegration (
      #   hm.nushell.mkNushellInline (nushellLine cfg.theme)
      # );
      # programs.zsh.initExtra = mkIf cfg.enableZshIntegration (zshLine cfg.theme);
      xdg.configFile =
        {
          "vivid/filetypes.yml" = mkIf (builtins.length (builtins.attrNames cfg.filetypes) > 0) {
            source = yaml.generate "filetypes.yml" cfg.filetypes;
          };
        }
        // mapAttrs' (
          name: value:
          nameValuePair "vivid/themes/${name}.yml" {
            source = yaml.generate "${name}.yml" value;
          }
        ) cfg.themes;
    };
}
