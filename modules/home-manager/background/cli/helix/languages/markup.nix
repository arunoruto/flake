{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.markup.enable = lib.mkEnableOption "Helix Markup config";

  config = lib.mkIf config.helix.markup.enable {
    programs.helix = {
      languages = {
        language = [
          {
            name = "json";
            # auto-format = true;
            # rulers = [120];
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "json"
              ];
            };
            language-servers = [ "vscode-json-languageserver" ];
          }
          {
            name = "yaml";
            auto-format = true;
            indent = {
              tab-width = 2;
              unit = " ";
            };
            formatter = {
              command = "yamlfmt";
              args = [ "-" ];
            };
            language-servers = [ "yaml-lsp" ];
          }
          {
            name = "toml";
            auto-format = true;
            formatter = {
              command = "taplo";
              args = [
                "fmt"
                "-"
              ];
            };
            language-servers = [ "taplo" ];
          }
          {
            name = "xml";
            language-servers = [ "lemminx" ];
          }
        ];
        language-server = {
          vscode-json-languageserver = {
            command = "vscode-json-languageserver";
            args = [ "--stdio" ];
          };
          yaml-lsp = {
            command = lib.getExe pkgs.yaml-language-server;
            args = [ "--stdio" ];
          };
          lemminx.command = "lemminx";
          taplo.command = "taplo lsp stdio";
        };
      };
      extraPackages = with pkgs; [
        lemminx
        taplo
        yaml-language-server
        yamlfmt
        nodePackages.prettier
        nodePackages.vscode-json-languageserver
        # nodePackages.prettier-plugin-toml
      ];
    };
  };
}
