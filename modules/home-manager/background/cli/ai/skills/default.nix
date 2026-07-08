{
  lib,
  pkgs,
  ...
}:
{
  options.ai.skills = lib.mkOption {
    type = with lib.types; either (attrsOf (either lines path)) path;
    default = { };
    description = ''
      Shared AI agent skills, consumed by opencode, claude-code, and other agents.

      This option can either be:
      - An attribute set defining skills
      - A path to a directory containing multiple skill folders

      If an attribute set is used, the attribute name becomes the skill directory name,
      and the value is either:
      - Inline content as a string (creates `<agent>/skill/<name>/SKILL.md`)
      - A path to a file (creates `<agent>/skill/<name>/SKILL.md`)
      - A path to a directory (creates `<agent>/skill/<name>/` with all files)

      If a path is used, it is expected to contain one folder per skill name, each
      containing a {file}`SKILL.md`.
    '';
  };

  config.ai.skills =
    let
      skillsDir = ./.;
    in
    {
      # caveman = pkgs.caveman + "/plugins/caveman/skills/caveman";
      commit = skillsDir + /commit;
      git-commit-nixpkgs = skillsDir + /git-commit-nixpkgs;
      # devenv = skillsDir + /devenv;
    };
}
