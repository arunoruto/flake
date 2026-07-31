# EDITOR/VISUAL for the chosen `devix.defaultEditor`. Both the command map
# and defaultEditor's enum come from the consumer registry, so every accepted
# value resolves here by construction.
{ config, lib, ... }:

let
  consumers = import ../../consumers/registry.nix { inherit lib; };
  cfg = config.devix;
in
{
  config = lib.mkIf (cfg.enable && cfg.defaultEditor != null) {
    home.sessionVariables = {
      EDITOR = consumers.editorCommands.${cfg.defaultEditor};
      VISUAL = consumers.editorCommands.${cfg.defaultEditor};
    };
  };
}
