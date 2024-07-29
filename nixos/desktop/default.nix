{lib, ...}: {
  imports = [
    ./gnome.nix
    ./hyprland.nix
    ./kde.nix
    ./sway.nix
  ];

  gnome.enable = lib.mkDefault true;
  kde.enable = lib.mkDefault false;
  sway.enable = lib.mkDefault true;
  hyprland.enable = lib.mkDefault true;
}
