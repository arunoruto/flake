{lib, ...}: {
  imports = [
    ./packages.nix
    ./firefox.nix
    ./fonts.nix
    ./ld.nix
    ./steam.nix
    ./chrome.nix
    ./programming.nix
    ./python.nix

    # ./wayland.nix
  ];

  chrome.enable = lib.mkDefault true;
  firefox.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault true;
}
