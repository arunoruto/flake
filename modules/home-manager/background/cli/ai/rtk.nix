{
  config,
  lib,
  pkgs,
  ...
}:
let
  package = pkgs.unstable.rtk;
  jsonFormat = pkgs.formats.json { };
  tomlFormat = pkgs.formats.toml { };

  # `rtk init -g` registers its hook in ~/.claude/settings.json, which Claude
  # Code keeps writing to (model, effort, plugins), so it can't be handed to
  # home-manager. A plugin carries the same PreToolUse hook instead; its files
  # are copied, not linked, as Claude Code reads hooks.json without following
  # symlinks.
  claudePlugin = pkgs.runCommand "rtk-claude-plugin" { } ''
    install -Dm644 ${
      jsonFormat.generate "plugin.json" {
        name = "rtk";
        inherit (package) version;
        description = package.meta.description;
      }
    } $out/.claude-plugin/plugin.json
    install -Dm644 ${
      jsonFormat.generate "hooks.json" {
        hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "${lib.getExe package} hook claude";
              }
            ];
          }
        ];
      }
    } $out/hooks/hooks.json
  '';

  # What `rtk init` writes as RTK.md: tells the agent output is condensed and
  # how to get the raw output back (`rtk proxy <cmd>`).
  awareness = "${package.src}/hooks/rtk-awareness.md";

  # rtk only looks for its hook in settings.json and would otherwise print a
  # daily "no hook installed" warning into the agent's command output.
  settings = tomlFormat.generate "rtk-config.toml" { hooks.suppress_hook_warning = true; };
in
{
  config = lib.mkMerge [
    (lib.mkIf (config.programs.claude-code.enable || config.programs.opencode.enable) (
      lib.mkMerge [
        { home.packages = [ package ]; }
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux { xdg.configFile."rtk/config.toml".source = settings; })
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.file."Library/Application Support/rtk/config.toml".source = settings;
        })
      ]
    ))
    (lib.mkIf config.programs.claude-code.enable {
      programs.claude-code.plugins = [ claudePlugin ];
      home.file."${config.programs.claude-code.configDir}/rules/rtk.md".source = awareness;
    })
    (lib.mkIf config.programs.opencode.enable {
      xdg.configFile."opencode/plugins/rtk.ts".source = "${package.src}/hooks/opencode/rtk.ts";
      programs.opencode.settings.instructions = [ awareness ];
    })
  ];
}
