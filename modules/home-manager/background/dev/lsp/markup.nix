{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;

  yamlEnabled = cfg.languages.yaml.enable or false;
  jsonEnabled = cfg.languages.json.enable or false;
  tomlEnabled = cfg.languages.toml.enable or false;
  xmlEnabled = cfg.languages.xml.enable or false;
in
{
  programs.dev.lsp.servers = {
    yaml-lsp = {
      enable = yamlEnabled;
      tags = [ "yaml" ];
      package = pkgs.yaml-language-server;
      command = lib.getExe pkgs.yaml-language-server;
      args = [ "--stdio" ];
    };

    vscode-json-languageserver = {
      enable = jsonEnabled;
      tags = [ "json" ];
      package = pkgs.nodePackages.vscode-json-languageserver;
      command = lib.getExe pkgs.nodePackages.vscode-json-languageserver;
      args = [ "--stdio" ];
    };

    taplo = {
      enable = tomlEnabled;
      tags = [ "toml" ];
      package = pkgs.taplo;
      command = lib.getExe pkgs.taplo;
      args = [ "lsp" "stdio" ];
    };

    lemminx = {
      enable = xmlEnabled;
      tags = [ "xml" ];
      package = pkgs.lemminx;
      command = lib.getExe pkgs.lemminx;
    };
  };
}
