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
    main = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "wezterm";
      description = ''
        Main terminal to be used, for example in shortcuts.
        This one will be always enabled!
      '';
    };
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
    programs = {
      alacritty.enable = lib.mkDefault false;
      ghostty.enable = lib.mkDefault true;
      warp.enable = lib.mkDefault false;
      wezterm.enable = lib.mkDefault true;
    };

    # home.packages = [ inputs.ghostty.packages.x86_64-linux.default ];
  };
}
