{lib, ...}: {
  imports = [
    ./avahi.nix
    ./tailscale.nix
  ];

  local-resolv.enable = lib.mkDefault true;
  tailscale.enable = lib.mkDefault true;
}
