{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./gemini.nix
    ./mcp.nix
    ./opencode.nix
  ];

  config = lib.mkIf config.hosts.development.enable {
    programs = {
      gemini-cli.enable = true;
      mcp.enable = true;
      opencode.enable = true;
    };
    home.packages = with pkgs.unstable; [
      goose-cli
      github-copilot-cli
    ];
  };
}
