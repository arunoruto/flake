{lib, ...}: {
  imports = [
    ./packages.nix
    ./cachix.nix
    ./firefox.nix
    ./fonts.nix
    ./ld.nix
    ./steam.nix
    ./chrome.nix
    ./programming.nix
    ./python.nix

    ./wayland.nix

    ./amd.nix
    ./intel.nix
  ];

  cachix.enable = lib.mkDefault true;
  chrome.enable = lib.mkDefault true;
  firefox.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault true;

  amd.enable = lib.mkDefault false;
  intel.enable = lib.mkDefault false;
}
