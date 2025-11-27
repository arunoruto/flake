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
        selectedAuthType = "oauth-personal";
        mcpServers = config.programs.mcp.servers;
      };
    };
    home.packages = [
      pkgs.unstable.github-mcp-server
    ];
  };
}
