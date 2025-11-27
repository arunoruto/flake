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
            # command = "mcp-github";
            # args = [ "stdio" ];
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
    };
    # home.packages = [
    #   pkgs.unstable.github-mcp-server
    # ];
  };
}
