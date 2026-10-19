# Plasma 6, usable next to GNOME: GDM stays the display manager and lists
# both sessions. KWallet needs no PAM setup of its own here, since GDM's
# gdm-password stack pulls in `login`, which the plasma6 module already
# hooks (next to gnome-keyring).
{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.desktopManager.plasma6.enable {
    # Same trimming as GNOME's excludePackages: no bundled terminal (Dolphin
    # opens terminals.main instead, see the home-manager plasma module),
    # no music player, no help browser.
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
      konsole
    ];
  };
}
