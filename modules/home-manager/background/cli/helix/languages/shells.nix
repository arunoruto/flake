{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.shells.enable = lib.mkEnableOption "Helix shells config";

  config = lib.mkIf config.helix.shells.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "bash";
            auto-format = true;
            formatter.command = "shfmt";
            indent = {
              tab-width = 2;
              unit = " ";
            };
          }
          {
            name = "fish";
            auto-format = true;
            formatter.command = "fish_indent";
            language-servers = [ "fish-lsp" ];
          }
          {
            name = "nu";
            auto-format = true;
            formatter.command = "nufmt";
          }
        ];
        language-server = {
          fish-lsp = {
            command = "fish-lsp";
            args = [ "start" ];
          };
        };
      };
      extraPackages = with pkgs; [
        bash-language-server
        fish
        fish-lsp
        nufmt
        shfmt
      ];
    };
  };
}
