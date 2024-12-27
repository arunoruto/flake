{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ghostty;
  keyValue = pkgs.formats.keyValue {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };
in
{
  meta.maintainers = [ lib.maintainers.HeitorAugustoLN ];

  options.programs.ghostty = {
    enable = lib.mkEnableOption "ghostty";
    package = lib.mkPackageOption pkgs "ghostty" { };
    settings = lib.mkOption {
      inherit (keyValue) type;
      default = { };
      example = lib.literalExpression ''
        {
          theme = "catppuccin-mocha";
          font-size = 10;
        }
      '';
      description = ''
        Configuration written to $XDG_CONFIG_HOME/ghostty/config.

        See https://ghostty.org/docs/config/reference for more information.
      '';
    };

    installBatSyntax = lib.mkEnableOption "installation of ghostty configuration syntax for bat" // {
      default = true;
    };
    installVimSyntax = lib.mkEnableOption "installation of ghostty configuration syntax for vim/neovim";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];

        xdg.configFile."ghostty/config" = lib.mkIf (cfg.settings != { }) {
          source = keyValue.generate "ghostty-config" cfg.settings;
        };
      }
      (lib.mkIf cfg.installBatSyntax {
        programs.bat = {
          syntaxes.ghostty = {
            src = cfg.package;
            file = "share/bat/syntaxes/ghostty.sublime-syntax";
          };
          config.map-syntax = [ "*/ghostty/config:Ghostty Config" ];
        };
      })
      (lib.mkIf cfg.installVimSyntax {
        programs.vim.plugins = [ cfg.package.vim ];
        programs.neovim.plugins = [ cfg.package.vim ];
      })
    ]
  );
}
