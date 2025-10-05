{ lib, pkgs, ... }:
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

  services = {
    tailscale = {
      enable = lib.mkDefault true;
      tailnet = lib.mkDefault "sparrow-yo";
    };
    netbird.enable = lib.mkDefault false;
  };
  programs = {
    localsend.enable = lib.mkDefault true;
  };
  environment.systemPackages = with pkgs; [ wireguard-tools ];
}
