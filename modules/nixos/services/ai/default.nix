{
  config,
  lib,
  ...
}:
{
  imports = [
    ./docling.nix
    ./docs-mcp-server.nix
    ./ollama.nix
    ./open-webui.nix
  ];
  options.services.ai.enable = lib.mkEnableOption "Enable local AI services";

  config = lib.mkIf config.services.ai.enable {
    services = {
      docs-mcp-server.enable = lib.mkDefault true;
      ollama.enable = lib.mkDefault true;
      open-webui.enable = lib.mkDefault true;
    };
  };

}
