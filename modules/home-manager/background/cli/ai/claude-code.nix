{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.claude-code.enable {
    programs.claude-code = {
      # package = pkgs.unstable.claude-code;
      package = pkgs.custom.claude-code;
      # settings = {
      #   general = {
      #     previewFeatures = true;
      #   };
      #   selectedAuthType = "oauth-personal";
      #   mcpServers = config.programs.mcp.servers;
      # };
      enableMcpIntegration = lib.mkDefault true;
      agents = config.ai.agentsClaude;
      skills = config.ai.skills;

    };
  };
}
