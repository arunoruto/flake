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
        Shared AI agent skills, consumed by opencode, claude-code, and codex.

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

        Every one is made manual-only: it runs on an explicit `/name` and the
        agent neither lists its description nor loads it on its own, so an
        unused skill costs no context.
      '';
    };
  };

  config =
    let
      # disable-model-invocation is Claude Code's switch; the metadata keys are OpenCode's.
      manualOnly =
        name: src:
        pkgs.runCommand "skill-${name}" { nativeBuildInputs = [ pkgs.yq-go ]; } ''
          cp -r ${src} $out
          chmod -R u+w $out
          yq -i --front-matter=process '
            .disable-model-invocation = true
            | .metadata."opencode/slash" = "true"
            | .metadata."opencode/autoinvoke" = "false"
          ' $out/SKILL.md
        '';
      skillPackages = lib.mapAttrs manualOnly config.ai.skillPackages;
    in
    {
      home.file = lib.mkIf config.programs.claude-code.enable (
        lib.mapAttrs' (
          name: source:
          lib.nameValuePair "${config.programs.claude-code.configDir}/skills/${name}" { inherit source; }
        ) skillPackages
      );

      xdg.configFile = lib.mkIf config.programs.opencode.enable (
        lib.mapAttrs' (
          name: source: lib.nameValuePair "opencode/skills/${name}" { inherit source; }
        ) skillPackages
      );

      ai = {
        skillPackages =
          let
            from = pkg: lib.flip lib.genAttrs (name: "${pkg}/share/skills/${pkg.pname}/${name}");
          in
          with pkgs.agentSkills;
          from anatomy [ "anatomy" ]
          // from humanizer [ "humanizer" ]
          // from typst-skill [ "typst" ]
          // from scientific-agent-skills [
            "scientific-visualization"
            "scientific-writing"
            "statistical-analysis"
            "uncertainty-and-units"
            "venue-templates"
          ]
          // from scicomp-research-skills [ "research-software-engineering" ]
          // from rseng-agent-skills [
            "rseng-archiving"
            "rseng-citation-metadata"
            "rseng-numerical-accuracy"
            "rseng-reproducibility"
            "rseng-testing"
          ];

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
