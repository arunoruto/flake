{ lib, pkgs, ... }:
{
  config = {
    services.tailscale = {
      # package = pkgs.unstable.tailscale;
      package = if (pkgs ? "unstable") then pkgs.unstable.tailscale else pkgs.tailscale;
    };
  };
}
