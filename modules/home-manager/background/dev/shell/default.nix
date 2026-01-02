{ config, lib, ... }:
let
  copilotSecretPath = lib.attrByPath [ "sops" "secrets" "tokens/copilot" "path" ] null config;
in
{
  config =
    lib.mkIf
      (
        config.programs.dev.enable
        && config.programs.dev.lsp.servers.gpt.enable
        && copilotSecretPath != null
      )
      {
        programs = {
          zsh.initContent = ''
            export COPILOT_API_KEY="$(cat ${copilotSecretPath})"
            export HANDLER=copilot
          '';

          fish.interactiveShellInit = ''
            set -gx COPILOT_API_KEY (cat ${copilotSecretPath})
            set -gx HANDLER copilot
          '';
        };
      };
}
