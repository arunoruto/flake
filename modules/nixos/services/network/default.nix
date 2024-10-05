{lib, ...}: {
  imports = [
    ./avahi.nix
    ./localsend.nix
    ./netbird.nix
    ./tailscale.nix
  ];

  local-resolv.enable = lib.mkDefault true;
  localsend.enable = lib.mkDefault true;
  netbird.enable = lib.mkDefault false;
  tailscale.enable = lib.mkDefault true;
}
