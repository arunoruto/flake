{lib, ...}: {
  imports = [
    ./icons.nix
    ./stylix.nix
  ];

  theming.icons.enable = lib.mkDefault true;
}
