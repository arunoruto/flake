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
            formatter = {
              command = "prettier";
              args = [
                "--parser"
                "yaml"
              ];
            };
          }
          {
            name = "toml";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.taplo;
              args = [
                "fmt"
                "-"
              ];
            };
            language-servers = [ "taplo" ];
          }
          {
            name = "xml";
            # auto-format = true;
            # formatter = {
            #   command = "prettier";
            #   args = [
            #     "--parser"
            #     "yaml"
            #   ];
            # };
            language-servers = [ "lemminx" ];
          }
        ];
        language-server = {
          vscode-json-languageserver = {
            command = lib.getExe pkgs.nodePackages.vscode-json-languageserver;
            args = [ "--stdio" ];
          };
          lemminx.command = lib.getExe pkgs.lemminx;
          taplo.command = "${lib.getExe pkgs.taplo} lsp stdio";
        };
      };
      extraPackages = with pkgs; [
        ansible-language-server
        yaml-language-server
        nodePackages.prettier
        nodePackages.prettier-plugin-toml
      ];
    };
  };
}
