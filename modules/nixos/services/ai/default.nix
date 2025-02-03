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
        host = "0.0.0.0";
        loadModels = [ "deepseek-r1:14b" ];
        openFirewall = true;
        acceleration =
          if config.hosts.nvidia.enable then
            "cuda"
          else if config.hosts.amd.enable then
            "rocm"
          else
            null;
      };
    };
  };

}
