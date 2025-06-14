{ lib, ... }:
{
  imports = [
    ./tailscale

    ./avahi.nix
    ./cloudflared.nix
    ./ipv64.nix
    ./localsend.nix
    ./netbird.nix
    ./traefik.nix
  ];

  local-resolv.enable = lib.mkDefault true;
  localsend.enable = lib.mkDefault true;
  netbird.enable = lib.mkDefault false;

  services = {
    tailscale.enable = lib.mkDefault true;
  };
}
