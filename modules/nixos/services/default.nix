{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware
    ./input
    ./media
    ./network

    ./davmail.nix
    ./flatpak.nix
    ./oneapi.nix
    ./secrets.nix
    ./ssh.nix
  ];

  davmail.enable = lib.mkDefault false;
  secrets.enable = lib.mkDefault true;
  oneapi.enable = lib.mkDefault false;
  # oneapi.enable = lib.mkDefault true;
  ssh.enable = lib.mkDefault true;

  # services.xserver = {
  #   enable = true;
  #   xkb = {
  #     layout = "de";
  #     variant = "";
  #   };
  #   excludePackages = with pkgs; [
  #     xterm
  #   ];
  # };
}
