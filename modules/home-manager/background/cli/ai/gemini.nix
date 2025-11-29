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
        selectedAuthType = "oauth-personal";
        mcpServers = config.programs.mcp.servers;
      };
    };
    home.packages = [
      pkgs.unstable.github-mcp-server
    ];
    home.file.".gemini/settings.json".force = true;
  };
}
