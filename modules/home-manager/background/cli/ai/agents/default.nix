{
  lib,
  pkgs,
  config,
  ...
}:
let
  agentTypes = lib.types.submodule {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "When the agent should be used.";
      };
      content = lib.mkOption {
        type = lib.types.either lib.types.lines lib.types.path;
        description = "Agent system prompt body (no frontmatter).";
      };
      tools = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
      };
      temperature = lib.mkOption {
        type = lib.types.nullOr (lib.types.numbers.between 0 1);
        default = null;
      };
      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Model for claude-code (sonnet, opus, haiku, fable).";
      };
    };
  };

  toolNames = {
    bash = "Bash";
    write = "Write";
    edit = "Edit";
    read = "Read";
    webfetch = "WebFetch";
    skill = "Skill";
    mcp = "Mcp";
  };

  genOpenCode =
    name: cfg:
    let
      content = if lib.isPath cfg.content then builtins.readFile cfg.content else cfg.content;
      toolsLines = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (k: v: "  ${k}: ${lib.boolToString v}") cfg.tools
      );
      tempLine = lib.optionalString (
        cfg.temperature != null
      ) "temperature: ${builtins.toJSON cfg.temperature}\n";
    in
    ''
      ---
      description: ${cfg.description}
      mode: subagent
      ${tempLine}tools:
      ${toolsLines}
      ---
      ${content}
    '';

  genClaude =
    name: cfg:
    let
      content = if lib.isPath cfg.content then builtins.readFile cfg.content else cfg.content;
      enabled = builtins.attrNames (lib.filterAttrs (_: v: v) cfg.tools);
      toolsStr =
        lib.optionalString (enabled != [ ])
          "tools: ${lib.concatStringsSep ", " (map (k: toolNames.${k}) enabled)}\n";
      modelStr = lib.optionalString (cfg.model != null) "model: ${cfg.model}\n";
    in
    ''
      ---
      name: ${name}
      description: ${cfg.description}
      ${modelStr}${toolsStr}---
      ${content}
    '';

  process = lib.mapAttrs (
    name: value:
    if builtins.isAttrs value && value ? description then
      {
        opencode = genOpenCode name value;
        claude = genClaude name value;
      }
    else
      {
        opencode = value;
        claude = value;
      }
  );
in
{
  options.ai = {
    agents = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either agentTypes lib.types.path);
      default = { };
      description = ''
        Shared AI agents, consumed by opencode and claude-code.

        Each entry can be either:
        - An attribute set with `description`, `content`, `tools`, etc. (frontmatter auto-generated)
        - A path to an existing agent file (used as-is for both tools)
      '';
    };

    agentsOpenCode = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
      default = { };
      internal = true;
    };

    agentsClaude = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
      default = { };
      internal = true;
    };
  };

  config = {
    ai.agents = {
      commit = {
        description = "Generates conventional commit messages from diffs";
        content = ./COMMIT.md;
        tools = {
          bash = false;
          write = false;
          edit = false;
          webfetch = false;
          mcp = false;
        };
        temperature = 0.1;
      };
      summirizer = {
        description = "Deeply analyzes text using structured reasoning (CoT, ToT) to extract core meaning.";
        content = ./ACADEMIC-SUMMARIZER.md;
        tools = {
          read = true;
          webfetch = true;
          write = true;
          edit = false;
          bash = false;
        };
        temperature = 0.1;
      };
      questioner = {
        description = "Analyzes text using structured reasoning (CoT, ToT) to generate deep insights and essential questions.";
        content = ./ACADEMIC-QUESTIONER.md;
        tools = {
          read = true;
          webfetch = true;
          write = true;
          edit = false;
          bash = false;
        };
        temperature = 0.1;
      };
      fable = {
        description = "Claude Fable 5 persona and behavioral rules";
        content = ./FABLE.md;
        tools = {
          bash = true;
          write = true;
          edit = true;
          read = true;
          webfetch = true;
          skill = true;
          mcp = true;
        };
      };
    };

    ai.agentsOpenCode = lib.mapAttrs (_: v: v.opencode) (process config.ai.agents);
    ai.agentsClaude = lib.mapAttrs (_: v: v.claude) (process config.ai.agents);
  };
}
