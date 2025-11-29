{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.mcp.enable {
    programs.mcp.servers = {
      github =
        if config.programs.gh.enable then
          {
            type = "stdio";
            command = lib.getExe (
              pkgs.writeShellApplication {
                name = "github-mcp.sh";
                runtimeInputs = with pkgs; [
                  gh
                  unstable.github-mcp-server
                ];
                text = ''
                  GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token) github-mcp-server stdio
                '';
              }
            );
          }
        else
          { };
      context7 = {
        type = "stdio";
        command = lib.getExe (
          pkgs.writeShellApplication {
            name = "context7.sh";
            runtimeInputs = with pkgs; [ context7 ];
            text = ''
              context7-mcp --api-key "$(cat ${config.sops.secrets."tokens/context7".path})"
            '';
          }
        );
      };
      # docs-mcp-server = {
      #   type = "sse";
      #   url = "http://madara.king-little.ts.net:6280/sse";
      # };
    };
    # home.packages = [
    #   pkgs.unstable.github-mcp-server
    # ];

    sops.secrets."tokens/context7" = { };
  };
}
