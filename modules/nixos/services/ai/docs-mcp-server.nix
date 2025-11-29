{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./docs-mcp-server-module.nix ];

  config = lib.mkIf config.services.docs-mcp-server.enable {
    services.docs-mcp-server = {
      package = pkgs.docs-mcp-server;
      environment = {
        HOST = "0.0.0.0";
        OPENAI_API_KEY = "ollama";
        OPENAI_API_BASE =
          if config.services.ollama.enable then
            "http://localhost:${builtins.toString config.services.ollama.port}/v1"
          else
            "http://129.217.143.158:11434/v1";
        DOCS_MCP_EMBEDDING_MODEL = "openai:embeddinggemma:300m";
        DOCS_MCP_TELEMETRY = false;
      };
      verbose = false;
    };
  };

}
