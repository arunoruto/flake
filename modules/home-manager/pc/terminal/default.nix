{
  lib,
  config,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./warp.nix
    ./wezterm.nix
  ];

  options.terminals.enable = lib.mkEnableOption "Enable configured terminals";

  config = lib.mkIf config.terminals.enable {
    terminals = {
      alacritty.enable = lib.mkDefault false;
      warp.enable = lib.mkDefault false;
      wezterm.enable = lib.mkDefault true;
    };
  };
}
