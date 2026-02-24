{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = {
    services.tailscale = {
      # package = pkgs.unstable.tailscale;
      package = if (pkgs ? "unstable") then pkgs.unstable.tailscale else pkgs.tailscale;
    };
    environment.shellAliases = lib.mkIf (!config.services.tailscale.enable) {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };
  };
}
