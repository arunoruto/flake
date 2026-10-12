{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ai = {
    skills = lib.mkOption {
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

    skillsExclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "devenv" ];
      description = "Skill directory names to exclude from auto-discovery.";
    };

    skillPackages = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      example = lib.literalExpression ''
        { anatomy = "''${pkgs.agentSkills.anatomy}/share/skills/anatomy/anatomy"; }
      '';
      description = ''
        Skill directories from packages, linked as a whole into each agent's
        skills directory. Unlike {option}`ai.skills`, the agents' modules never
        inspect them, so evaluation does not have to build or fetch the package
        (no import-from-derivation).
      '';
    };
  };

  config = {
    home.file = lib.mkIf config.programs.claude-code.enable (
      lib.mapAttrs' (
        name: source:
        lib.nameValuePair "${config.programs.claude-code.configDir}/skills/${name}" { inherit source; }
      ) config.ai.skillPackages
    );

    xdg.configFile = lib.mkIf config.programs.opencode.enable (
      lib.mapAttrs' (
        name: source: lib.nameValuePair "opencode/skills/${name}" { inherit source; }
      ) config.ai.skillPackages
    );

    ai = {
      skillPackages.anatomy = "${
        pkgs.agentSkills.anatomy.override { manualOnly = true; }
      }/share/skills/anatomy/anatomy";

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
  };
}
