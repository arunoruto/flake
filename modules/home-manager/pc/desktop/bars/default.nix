{lib, ...}: {
  imports = [
    ./ags
    ./eww
    ./waybar
  ];

  ags.enable = lib.mkDefault false;
  eww.enable = lib.mkDefault true;
}
