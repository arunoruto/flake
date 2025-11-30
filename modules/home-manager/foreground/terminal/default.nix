{
  inputs,
  lib,
  config,
  ...
}:
let
  terminals = [
    "alacritty"
    "ghostty"
    "warp"
    "wezterm"
  ];
in
{
  imports = [
    ./alacritty.nix
    ./ghostty
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
    programs =
      (lib.genAttrs terminals (
        # loops over all terminal attributes defined above
        term:
        lib.genAttrs [ "enable" ] (
          # for the enable attribute
          val: lib.mkDefault (if config.terminals.main == term then true else false)
        )
      ))
      // {
        # # here you can force a terminal to be enabled!
        # alacritty.enable = lib.mkForce true;
        # warp.enable = true;
      };
  };
}
