{
  config,
  lib,
  ...
}:
{
  imports = [
    ./nix.nix
  ];

  system.defaults = {
    dock = {
      autohide = lib.mkDefault true;
      autohide-delay = 0.25;
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
    userKeyMapping = [
      (lib.mkIf config.system.keyboard.remapCapsLockToEscape {
        HIDKeyboardModifierMappingSrc = 30064771113;
        HIDKeyboardModifierMappingDst = 30064771129;
      })
    ];
  };

}
