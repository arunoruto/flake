{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./avahi.nix
    ./fingerprint.nix
    ./flatpak.nix
    ./fwupd.nix
    ./printing.nix
    ./scanning.nix
    ./sound.nix
    ./ssd.nix
    ./tailscale.nix
    ./vial.nix
  ];

  local-resolv.enable = lib.mkDefault true;
  fingerprint.enable = lib.mkDefault false;
  flatpak.enable = lib.mkDefault false;
  fwupd.enable = lib.mkDefault true;
  printing.enable = lib.mkDefault false;
  scanning.enable = lib.mkDefault false;
  sound.enable = lib.mkDefault true;
  drive-optimizations.enable = lib.mkDefault true;
  tailscale.enable = lib.mkDefault true;
  vial.enable = lib.mkDefault true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "";
    };
    excludePackages = with pkgs; [
      xterm
    ];
  };
}
