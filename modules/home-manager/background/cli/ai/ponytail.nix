{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.programs.claude-code.enable {
      programs.claude-code.plugins = [ pkgs.agentSkills.ponytail ];
    })
    (lib.mkIf config.programs.opencode.enable {
      programs.opencode.settings.plugin = [
        "${pkgs.agentSkills.ponytail}/.opencode/plugins/ponytail.mjs"
      ];
    })
  ];
}
