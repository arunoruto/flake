{ lib, config, ... }:
{
  imports = [
    ./eurkey.nix
  ];

  config = {
    system.keyboard = {
      enableKeyMapping = lib.mkDefault true;
      remapCapsLockToEscape = lib.mkDefault true;
      swapLeftCtrlAndFn = lib.mkDefault true;
      nonUS.remapTilde = lib.mkDefault true;
      userKeyMapping = [
        (lib.mkIf config.system.keyboard.remapCapsLockToEscape {
          HIDKeyboardModifierMappingSrc = 30064771113;
          HIDKeyboardModifierMappingDst = 30064771129;
        })
      ];
    };
  };
}
