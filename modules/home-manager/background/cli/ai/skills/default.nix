{
  config,
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

      By default, skills are auto-discovered from {file}`.agents/skills/` at the
      flake root and this skill directory. Only subdirectories are included.
    '';
  };

  options.ai.skillsExclude = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "devenv" ];
    description = "Skill directory names to exclude from auto-discovery.";
  };

  config.ai = {
    skillsExclude = [ "devenv" ];
    skills =
      let
        skillsDir = ./.;
        flakeSkillsDir = ../../../../../../.agents/skills;

        discoverSkills =
          dir: excluded:
          let
            entries = builtins.readDir dir;
          in
          builtins.listToAttrs (
            map
              (name: {
                inherit name;
                value = dir + "/${name}";
              })
              (
                builtins.filter (name: entries.${name} == "directory" && !(builtins.elem name excluded)) (
                  builtins.attrNames entries
                )
              )
          );
      in
      (discoverSkills flakeSkillsDir config.ai.skillsExclude)
      // (discoverSkills skillsDir config.ai.skillsExclude);
  };
}
