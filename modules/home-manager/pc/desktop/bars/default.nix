{ lib, ... }:
{
  imports = [
    # ./ags
    ./eww
    ./waybar
  ];

  bars = {
    # ags.enable = lib.mkDefault false;
    eww.enable = lib.mkDefault true;
    waybar.enable = lib.mkDefault false;
  };
}
