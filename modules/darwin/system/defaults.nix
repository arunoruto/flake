{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.darwin.system = {
    defaults.enable = lib.mkEnableOption "Enable macOS system defaults configuration" // {
      default = true;
    };
  };

  config = lib.mkIf config.darwin.system.defaults.enable {
    system.defaults = {
      dock = {
        autohide = lib.mkDefault true;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = lib.mkDefault true;
        FXEnableExtensionChangeWarning = lib.mkDefault false;
      };

      # Trackpad settings
      trackpad = {
        Clicking = lib.mkDefault true;
        TrackpadRightClick = lib.mkDefault true;
      };
    };

    # Keyboard settings
    system.keyboard = {
      enableKeyMapping = lib.mkDefault true;
      remapCapsLockToEscape = lib.mkDefault true;
      swapLeftCtrlAndFn = lib.mkDefault true;
    };
  };
}
