{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.mcp.enable {
    programs.mcp.servers = lib.mkMerge [
      (lib.mkIf config.programs.gh.enable {
        github = {
          disabled = true;
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
        };
      })
      {
        context7 = {
          disabled = true;
          type = "stdio";
          command = lib.getExe (
            pkgs.writeShellApplication {
              name = "context7.sh";
              runtimeInputs = with pkgs; [ context7-mcp ];
              text = ''
                context7-mcp --api-key "$(cat ${config.sops.secrets."tokens/context7".path})"
              '';
            }
          );
        };
        devenv = {
          disabled = true;
          type = "remote";
          url = "https://mcp.devenv.sh";
        };
        # docs-mcp-server = {
        #   type = "sse";
        #   url = "http://madara.king-little.ts.net:6280/sse";
        # };
        # gh_grep = {
        #   type = "remote";
        #   url = "https://mcp.grep.app";
        # };
      }
    ];
    # home.packages = [
    #   pkgs.unstable.github-mcp-server
    # ];

    sops.secrets."tokens/context7" = { };
  };
}
