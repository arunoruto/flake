# Home-manager default editor environment integration
{ config, lib, ... }:

let
  cfg = config.development;
  editorCommands = {
    helix = "hx";
    zed = "zed --wait";
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.defaultEditor != null) {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.defaultEditor editorCommands;
        message = "development.defaultEditor has no Home Manager editor command: ${cfg.defaultEditor}";
      }
    ];

    home.sessionVariables = {
      EDITOR = editorCommands.${cfg.defaultEditor};
      VISUAL = editorCommands.${cfg.defaultEditor};
    };
  };
}
