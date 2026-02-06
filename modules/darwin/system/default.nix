{
  config,
  lib,
  ...
}:
{
  imports = [
    ./keyboard
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
}
