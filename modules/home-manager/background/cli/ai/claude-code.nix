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
      enableMcpIntegration = lib.mkDefault true;
      skills =
        let
          folder = ./skills;
        in
        {
          # beads = pkgs.unstable.beads.src + "/skills/beads";
          beads = pkgs.unstable.beads.src + "/claude-plugin/skills/beads";
          # caveman = pkgs.caveman + "/skills/caveman";
          commit = folder + /commit;
          git-commit-nixpkgs = folder + /git-commit-nixpkgs;
          devenv = folder + /devenv;
          caveman =
            (pkgs.fetchFromGitHub {
              owner = "JuliusBrussee";
              repo = "caveman";
              tag = "v1.3.5";
              hash = "sha256-EAlKoqJuTMib+gcLscMtpS8Zzq/D/LmIRoG3g/XKThc=";
            })
            + "/plugins/caveman/skills/caveman";
        };

    };
  };
}
