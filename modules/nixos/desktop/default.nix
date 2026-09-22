# What a `desktop`-tagged host gets: GDM and GNOME by default, the X server
# with this flake's XKB layout, and the XDG portals (./wayland.nix). The
# other sessions (hyprland.nix, sway.nix, niri.nix, kodi.nix) switch on with
# their own upstream toggles.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dm
    ./gnome.nix
    ./hyprland.nix
    ./kodi.nix
    ./sway.nix
    ./niri.nix
    ./wayland.nix # portals + wl-clipboard
  ];

  config = lib.mkIf (config.lib.tags.hasTag "desktop") {
    services = {
      displayManager.gdm.enable = lib.mkDefault true;
      desktopManager.gnome.enable = lib.mkDefault true;

      xserver = {
        enable = true;
        xkb = {
          layout = "de";
          variant = "us";
          # layout = "us";
          # variant = "altgr-intl";
        };
        excludePackages = with pkgs; [
          xterm
        ];
        exportConfiguration = true;
      };
    };
  };
}
