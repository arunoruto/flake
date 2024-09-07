{lib, ...}: {
  imports = [
    ./alacritty.nix
    ./warp.nix
    ./wezterm.nix
  ];

  alacritty.enable = lib.mkDefault false;
  warp.enable = lib.mkDefault true;
  wezterm.enable = lib.mkDefault true;
}
