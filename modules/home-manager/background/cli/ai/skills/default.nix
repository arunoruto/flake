{ lib, ... }:
{
  options.skills = lib.mkOption {
    type = with lib.types; either (attrsOf (either lines path)) path;
    default = { };
    description = ''
      Custom agent skills for agents.

      This option can either be:
      - An attribute set defining skills
      - A path to a directory containing multiple skill folders

      If an attribute set is used, the attribute name becomes the skill directory name,
      and the value is either:
      - Inline content as a string (creates `<agent>/skill/<name>/SKILL.md`)
      - A path to a file (creates `<agent>/skill/<name>/SKILL.md`)
      - A path to a directory (creates `<agent>/skill/<name>/` with all files)

      If a path is used, it is expected to contain one folder per skill name, each
      containing a {file}`SKILL.md`. The directory is symlinked to
      {file}`$XDG_CONFIG_HOME/<agent>/skill/`.
    '';
    example = lib.literalExpression ''
      {
        git-release = '''
          ---
          name: git-release
          description: Create consistent releases and changelogs
          ---

          ## What I do

          - Draft release notes from merged PRs
          - Propose a version bump
          - Provide a copy-pasteable `gh release create` command
        ''';

        # A skill can also be a directory containing SKILL.md and other files.
        data-analysis = ./skills/data-analysis;
      }
    '';
  };

  config = {

  };
}
