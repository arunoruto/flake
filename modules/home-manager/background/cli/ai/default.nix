{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./claude-code.nix
    ./copilot.nix
    ./gemini.nix
    ./mcp.nix
    ./opencode.nix
  ];

  options.programs.ollama.defaultPath = lib.mkOption {
    type = lib.types.str;
    default = "http://localhost:11434";
    description = "The default URL for the Ollama CLI to connect to.";
  };

  config = lib.mkIf config.hosts.development.enable {
    programs = {
      claude-code.enable = true;
      copilot-cli.enable = true;
      gemini-cli.enable = true;
      mcp.enable = true;
      ollama.defaultPath = "http://madara.king-little.ts.net:11434/v1";
      opencode.enable = true;
    };
    home.packages = with pkgs.unstable; [
      goose-cli
    ];
  };
}
