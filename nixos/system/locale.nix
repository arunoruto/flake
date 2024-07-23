{lib, ...}: {
  # Set your time zone.
  # time.timeZone = "Europe/Berlin";
  # allow TZ to be set by desktop user
  # time.timeZone = lib.mkForce null;
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_GB.UTF-8";
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
}
