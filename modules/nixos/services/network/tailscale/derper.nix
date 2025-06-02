{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.tailscale.derper.enable {
    services = {
      tailscale.derper = {
        package = pkgs.unstable.tailscale.derper;
        verifyClients = lib.mkDefault config.services.tailscale.enable;
      };
      nginx.enable = lib.mkForce false;
    };
  };
}
