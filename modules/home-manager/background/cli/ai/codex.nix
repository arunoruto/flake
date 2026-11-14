{
  config,
  lib,
  pkgs,
  ...
}:
let
  configDir = if config.home.preferXdgDirectories then "${config.xdg.configHome}/codex" else ".codex";
in
{
  config = lib.mkIf config.programs.codex.enable {
    programs.codex = {
      package = pkgs.unstable.codex;
      # Home Manager translates disabled servers, HTTP headers and file-backed
      # environment variables into Codex's native MCP configuration.
      enableMcpIntegration = true;
      skills = config.ai.skills;
      settings.project_doc_fallback_filenames = [ "CLAUDE.md" ];
    };

    # Link packaged skills directly: inspecting store paths through the skills
    # option would require building their packages during evaluation.
    home.file = lib.mapAttrs' (
      name: source: lib.nameValuePair "${configDir}/skills/${name}" { inherit source; }
    ) config.ai.skillPackages;
  };
}
