{ config, ... }:
{
  programs =
    let
      gemini-token = "cat ${config.sops.secrets."tokens/gemini".path}";
    in
    {
      zsh.initContent = ''
        export GEMINI_API_KEY="$(${gemini-token})"
      '';
      fish.interactiveShellInit = ''
        set -gx GEMINI_API_KEY $(${gemini-token})
      '';
    };

  sops.secrets."tokens/gemini" = { };
}
