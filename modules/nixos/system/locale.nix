{
  config,
  lib,
  ...
}: let
  british = "en_GB.UTF-8";
  german = "de_DE.UTF-8";
in {
  # Set keyboard layout in TTY
  # console.keyMap = config.services.xserver.xkb.variant ? config.services.xserver.xkb.layout;
  console.keyMap =
    if (config.services.xserver.xkb.variant != "") && (lib.stringLength config.services.xserver.xkb.variant == 2)
    then config.services.xserver.xkb.variant
    else config.services.xserver.xkb.layout;
  # Set your time zone.
  # time.timeZone = "Europe/Berlin";
  # allow TZ to be set by desktop user
  # time.timeZone = lib.mkForce null;
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = british;
  i18n = {
    defaultLocale = german;
    extraLocaleSettings = {
      LANGUAGE = british;
      LC_ALL = british;
      LC_ADDRESS = german;
      LC_IDENTIFICATION = german;
      LC_MEASUREMENT = german;
      LC_MONETARY = german;
      LC_NAME = german;
      LC_NUMERIC = german;
      LC_PAPER = german;
      LC_TELEPHONE = german;
      LC_TIME = german;
    };
  };
}
