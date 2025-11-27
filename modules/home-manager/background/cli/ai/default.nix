{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # ./opencode-module.nix
    ./gemini.nix
    ./mcp.nix
    ./opencode-theme.nix
  ];
  config = lib.mkIf config.hosts.development.enable {
    programs = {
      gemini-cli.enable = true;
      mcp.enable = true;
      opencode = {
        enable = true;
        package = pkgs.unstable.opencode;
        settings = {
          theme = "stylix";
        };
      };
    };
    home.packages = with pkgs.unstable; [
      goose-cli
      github-copilot-cli
    ];
  };
}
