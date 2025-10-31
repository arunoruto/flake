{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode-module.nix
    ./opencode-theme.nix
  ];
  config = lib.mkIf (!config.hosts.tinypc.enable) {
    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      settings = {
        theme = "stylix";
      };
    };
    home.packages = with pkgs.unstable; [
      gemini-cli
      goose-cli
      github-copilot-cli
    ];
  };
}
