{lib, ...}: {
  imports = [
    ./packages.nix
    ./fonts.nix
    ./steam.nix
    ./chrome.nix
    ./programming.nix
  ];

  chrome.enable = lib.mkDefault true;
  steam.enable = lib.mkDefault false;
}
