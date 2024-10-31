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
            # auto-format = true;
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
            # auto-format = true;
            # formatter = {
            #   command = "prettier";
            #   args = ["--plugin=${pkgs.nodePackages.prettier-plugin-toml}/lib/node_modules/prettier-plugin-toml" "--parser" "toml"];
            # };
          }
        ];
        language-server = {
          vscode-json-languageserver = {
            command = "vscode-json-languageserver";
            args = [ "--stdio" ];
          };
        };
      };
      extraPackages = with pkgs; [
        ansible-language-server
        taplo
        yaml-language-server
        nodePackages.prettier
        nodePackages.prettier-plugin-toml
        nodePackages.vscode-json-languageserver
      ];
    };
  };
}
