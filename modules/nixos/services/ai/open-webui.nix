{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.open-webui.enable {
    services.open-webui = {
      host = "0.0.0.0";
      environment = {
        WEBUI_AUTH = "False";
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";

        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };
  };

}
