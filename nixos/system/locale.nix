let
  british = "en_GB.UTF-8";
  german = "de_DE.UTF-8";
in {
  # Set your time zone.
  # time.timeZone = "Europe/Berlin";
  # allow TZ to be set by desktop user
  # time.timeZone = lib.mkForce null;
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = british;
  i18n.defaultLocale = german;

  i18n.extraLocaleSettings = {
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
}
