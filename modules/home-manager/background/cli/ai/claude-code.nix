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
      # package = pkgs.custom.claude-code;
      # settings = {
      #   general = {
      #     previewFeatures = true;
      #   };
      #   selectedAuthType = "oauth-personal";
      #   mcpServers = config.programs.mcp.servers;
      # };
      # Home Manager's own integration writes `"enabled": false` for servers that are off, which Claude
      # Code ignores and starts them anyway; so only the ones that are on go in.
      enableMcpIntegration = false;
      mcpServers =
        lib.mapAttrs
          (
            name: server:
            lib.hm.mcp.transformMcpServer {
              inherit server;
              exclude = [ "enabled" ];
              extraTransforms = [ (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; }) ];
            }
          )
          (
            lib.filterAttrs (
              _: server: if server.enabled or null != null then server.enabled else !(server.disabled or false)
            ) config.programs.mcp.servers
          );
      agents = config.ai.agentsClaude;
      skills = config.ai.skills;

    };
  };
}
