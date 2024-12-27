{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./ghostty.nix
    ./warp.nix
    ./wezterm.nix
  ];

  options.terminals = {
    enable = lib.mkEnableOption "Enable configured terminals";
    width = lib.mkOption {
      type = lib.types.int;
      default = 108;
      example = 108;
      description = "Number of characters in width";
    };
    height = lib.mkOption {
      type = lib.types.int;
      default = 36;
      example = 36;
      description = "Number of characters in height";
    };
  };

  config = lib.mkIf config.terminals.enable {
    terminals = {
      alacritty.enable = lib.mkDefault false;
      warp.enable = lib.mkDefault false;
      wezterm.enable = lib.mkDefault true;
    };

    # home.packages = [ inputs.ghostty.packages.x86_64-linux.default ];
  };
}
