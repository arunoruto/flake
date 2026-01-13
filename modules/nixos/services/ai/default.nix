{
  config,
  lib,
  ...
}:
{
  imports = [
    ./docs-mcp-server.nix
    ./ollama.nix
    ./open-webui.nix
  ];
  options.services.ai.enable = lib.mkEnableOption "Enable local AI services";

  config = lib.mkIf config.services.ai.enable {
    services = {
      docs-mcp-server.enable = true;
      ollama.enable = true;
      open-webui.enable = true;
    };
  };

}
