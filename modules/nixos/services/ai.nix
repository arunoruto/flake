{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.ai.enable = lib.mkEnableOption ''Enable local AI services'';

  config = lib.mkIf config.ai.enable {
    services = {
      open-webui = {
        enable = true;
        host = "0.0.0.0";
        environment = {
          WEBUI_AUTH = "False";
          OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";

          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";
        };
      };

      ollama = {
        enable = true;
        package = pkgs.unstable.ollama;
        # if config.hosts.nvidia.enable then
        #   pkgs.unstable.ollama-cuda
        # else if config.hosts.amd.enable then
        #   pkgs.unstable.ollama-rocm
        # else
        #   pkgs.unstable.ollama;
        host = "0.0.0.0";
        loadModels = [
          "deepseek-r1:14b"
          "gemma3:4b"
          "gemma3:12b"
          "mistral:7b"
        ];
        openFirewall = true;
        acceleration =
          if config.hosts.nvidia.enable then
            "cuda"
          else if config.hosts.amd.enable then
            "rocm"
          else
            null;
        environmentVariables = {
          OLLAMA_ORIGINS = "moz-extension://*";
        };
      };
    };
  };

}
