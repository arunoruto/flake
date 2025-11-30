{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./copilot-module.nix ];

  config = lib.mkIf config.programs.copilot-cli.enable {
    programs.copilot-cli = {
      package = pkgs.unstable.github-copilot-cli;
      enableMcpIntegration = true;
    };
  };
}
