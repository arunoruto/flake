{ pkgs, lib, ... }:
{
  programs.dev.languages = {
    json = {
      tags = [ "markup" ];
      extensions = [ ".json" ];
      lspServers = [ "vscode-json-languageserver" ];
      formatter = {
        package = pkgs.prettier;
        command = lib.getExe pkgs.prettier;
        args = [
          "--parser"
          "json"
        ];
      };
      packages = with pkgs; [
        prettier
        vscode-json-languageserver
      ];
    };

    yaml = {
      tags = [ "markup" ];
      extensions = [
        ".yaml"
        ".yml"
      ];
      autoFormat = true;
      lspServers = [ "yaml-lsp" ];
      formatter = {
        package = pkgs.yamlfmt;
        command = lib.getExe pkgs.yamlfmt;
        args = [ "-" ];
      };
      helix.languageConfig.indent = {
        tab-width = 2;
        unit = " ";
      };
      packages = with pkgs; [
        yaml-language-server
        yamlfmt
      ];
    };

    toml = {
      tags = [ "markup" ];
      extensions = [ ".toml" ];
      autoFormat = true;
      lspServers = [ "taplo" ];
      formatter = {
        package = pkgs.taplo;
        command = lib.getExe pkgs.taplo;
        args = [
          "fmt"
          "-"
        ];
      };
      packages = with pkgs; [ taplo ];
    };

    xml = {
      tags = [ "markup" ];
      extensions = [ ".xml" ];
      lspServers = [ "lemminx" ];
      packages = with pkgs; [ lemminx ];
    };
  };
}
