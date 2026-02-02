{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.keyboard = {
    layout = lib.mkOption {
      type = lib.types.str;
      default = "de";
      example = "de";
      description = "Set keyboard layout: localectl list-x11-keymap-layouts";
    };

    variant = lib.mkOption {
      type = lib.types.str;
      default = "us";
      example = "us";
      description = "Set keyboard variant: localectl list-x11-keymap-variants de";
    };

    # Note: EurKey is now installed system-wide via darwin module
    # See modules/darwin/keyboard/eurkey.nix
  };
}
