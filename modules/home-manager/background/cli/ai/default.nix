{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./copilot.nix
    ./gemini.nix
    ./mcp.nix
    ./opencode.nix
  ];

  config = lib.mkIf config.hosts.development.enable {
    programs = {
      copilot-cli.enable = true;
      gemini-cli.enable = true;
      mcp.enable = true;
      opencode.enable = true;
    };
    home.packages = with pkgs.unstable; [
      goose-cli
    ];
  };
}
