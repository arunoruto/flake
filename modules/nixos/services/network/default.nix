{lib, ...}: {
  imports = [
    ./avahi.nix
    ./localsend.nix
    ./tailscale.nix
  ];

  local-resolv.enable = lib.mkDefault true;
  localsend.enable = lib.mkDefault true;
  tailscale.enable = lib.mkDefault true;
}
