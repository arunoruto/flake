{lib, ...}: {
  imports = [
    ./libreoffice.nix
  ];

  libreoffice.enable = lib.mkDefault true;
}
