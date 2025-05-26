{ config, pkgs, ... }:
{
  programs = {
    helix = {
      languages.language-server.gpt = {
        command = "helix-gpt";
        args = [
          "--handler"
          "copilot"
        ];
      };

      extraPackages = with pkgs; [ helix-gpt ];
    };

    # Environmental Variables
    zsh.initContent = ''
      export COPILOT_API_KEY="$(cat ${config.sops.secrets."tokens/copilot".path})"
      export HANDLER=copilot
    '';
    fish.interactiveShellInit = ''
      set -gx COPILOT_API_KEY $(cat ${config.sops.secrets."tokens/copilot".path})
      set -gx HANDLER copilot
    '';
  };
}
