{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.gemini-cli.enable {
    programs.gemini-cli = {
      package = pkgs.unstable.gemini-cli;
      settings = {
        general = {
          previewFeatures = true;
        };
        contextFileName = [
          "GEMINI.md"
          "AGENTS.md"
        ];
        selectedAuthType = "oauth-personal";
        mcpServers = lib.attrsets.mapAttrs (
          _: v: lib.attrsets.filterAttrs (n: _: n != "type") v
        ) config.programs.mcp.servers;
      };
    };
    home.packages = [
      pkgs.unstable.github-mcp-server
    ];
    home.file.".gemini/settings.json".force = true;
  };
}
