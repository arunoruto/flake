{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.claude-code.enable {
    programs.claude-code = {
      package = pkgs.unstable.claude-code;
      # settings = {
      #   general = {
      #     previewFeatures = true;
      #   };
      #   selectedAuthType = "oauth-personal";
      #   mcpServers = config.programs.mcp.servers;
      # };
      mcpServers = config.programs.mcp.servers;
    };
    # home.file.".gemini/settings.json".force = true;
  };
}
